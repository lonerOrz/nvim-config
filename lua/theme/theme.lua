local M = {}

--------------------------------------------------------------------------------
-- Storage Layer
--------------------------------------------------------------------------------
local Storage = {}
Storage.FILE = vim.fn.stdpath("state") .. "/theme.state"
Storage.cached = nil

function Storage.get_saved_id()
	if Storage.cached then
		return Storage.cached
	end
	local ok, lines = pcall(vim.fn.readfile, Storage.FILE)
	Storage.cached = (ok and lines[1] and lines[1] ~= "") and lines[1] or "catppuccin"
	return Storage.cached
end

function Storage.save_id(id)
	Storage.cached = id
	pcall(vim.fn.writefile, { id }, Storage.FILE)
end

--------------------------------------------------------------------------------
-- Loader Layer
--------------------------------------------------------------------------------
local Loader = {}
Loader.cache = nil

local REQUIRED = {
	"rosewater",
	"flamingo",
	"pink",
	"mauve",
	"red",
	"maroon",
	"peach",
	"yellow",
	"green",
	"teal",
	"sky",
	"sapphire",
	"blue",
	"lavender",
	"text",
	"subtext1",
	"subtext0",
	"overlay2",
	"overlay1",
	"overlay0",
	"surface2",
	"surface1",
	"surface0",
	"base",
	"mantle",
	"crust",
}

function Loader.load(id)
	local ok, mod = pcall(require, "theme.themes." .. id)
	if not ok or type(mod) ~= "table" or not mod.colors then
		return nil
	end
	for _, key in ipairs(REQUIRED) do
		if not mod.colors[key] then
			vim.notify(("theme: %s missing color '%s'"):format(id, key), vim.log.levels.WARN)
			return nil
		end
	end
	return { id = id, name = mod.name or id, colors = mod.colors }
end

-- 显式失效 + 重读，仅用于磁盘上的主题文件变更
function Loader.reload(id)
	package.loaded["theme.themes." .. id] = nil
	return Loader.load(id)
end

function Loader.scan_all()
	if Loader.cache then
		return Loader.cache
	end
	local themes = {}
	local files = vim.api.nvim_get_runtime_file("lua/theme/themes/*.lua", true)
	for _, file in ipairs(files) do
		local id = vim.fs.basename(file):gsub("%.lua$", "")
		local theme = Loader.load(id)
		if theme then
			themes[#themes + 1] = theme
		else
			vim.notify(("theme: skipping %s (invalid module)"):format(id), vim.log.levels.WARN)
		end
	end
	table.sort(themes, function(a, b)
		return a.id < b.id
	end)
	Loader.cache = themes
	return themes
end

--------------------------------------------------------------------------------
-- Engine Layer
--------------------------------------------------------------------------------
local Engine = {
	current_id = nil,
	base_opts = {},
	theme = nil,
}

function Engine.preview(theme)
	local final_opts = vim.tbl_deep_extend("force", Engine.base_opts, {
		color_overrides = { all = theme.colors },
	})

	-- 先确认 catppuccin 可用，再更新内部状态，避免状态与实际主题不一致
	local ok, catppuccin = pcall(require, "catppuccin")
	if not ok then
		vim.notify("theme: catppuccin module not available", vim.log.levels.ERROR)
		return
	end

	Engine.current_id = theme.id
	Engine.theme = theme
	catppuccin.setup(final_opts)
	vim.cmd.colorscheme("catppuccin")
end

function Engine.render(theme)
	Storage.save_id(theme.id)
	Engine.preview(theme)
end

--------------------------------------------------------------------------------
-- UI Layer
--------------------------------------------------------------------------------
local UI = {}

-- 代际计数：用于取消过期的预览请求
local preview_generation = 0

function UI.register_command()
	vim.api.nvim_create_user_command("Theme", function(args)
		if args.args == "" then
			local cur = Loader.load(Engine.current_id or Storage.get_saved_id())
			print(cur and cur.name or Engine.current_id)
		else
			M.apply(args.args)
		end
	end, {
		nargs = "?",
		complete = function()
			return vim.tbl_map(function(d)
				return d.id
			end, Loader.scan_all())
		end,
	})
end

function UI.register_autocmd()
	vim.api.nvim_create_autocmd("BufWritePost", {
		pattern = "*/lua/theme/themes/*.lua",
		callback = function(args)
			local id = vim.fs.basename(args.file):gsub("%.lua$", "")
			Loader.cache = nil
			local theme = Loader.reload(id)
			if theme and (Engine.current_id or Storage.get_saved_id()) == id then
				-- 编辑中的主题可能暂时无效，静默失败，避免打断编辑
				pcall(Engine.preview, theme)
			end
		end,
	})
end

function UI.open_picker()
	local themes = Loader.scan_all()
	local orig_id = Engine.current_id or Storage.get_saved_id()
	for i, d in ipairs(themes) do
		if d.id == orig_id then
			table.remove(themes, i)
			table.insert(themes, 1, d)
			break
		end
	end

	-- 预先构建 name -> theme 映射，避免每次 preview 都线性扫描
	local by_name = {}
	for _, d in ipairs(themes) do
		if not by_name[d.name] then
			by_name[d.name] = d
		end
	end

	local ok, fzf = pcall(require, "fzf-lua")
	if not ok then
		vim.ui.select(themes, {
			prompt = "Select Colorscheme:",
			format_item = function(d)
				return ("%-20s (%s)"):format(d.name, d.id)
			end,
		}, function(selected)
			-- 取消任何待定的预览
			preview_generation = preview_generation + 1
			if selected then
				M.apply(selected.id)
			else
				local orig = Loader.load(orig_id)
				if orig then
					Engine.preview(orig)
				end
			end
		end)
		return
	end

	fzf.fzf_exec(
		vim.tbl_map(function(d)
			return d.name
		end, themes),
		{
			prompt = "Themes ❯ ",
			winopts = {
				height = 0.45,
				width = 0.55,
				row = 0.40,
				border = "rounded",
				preview = { layout = "horizontal", horizontal = "right:45%" },
			},
			preview = function(items)
				local t = items and by_name[items[1]]
				if not t then
					return ""
				end

				-- 用独立 defer + 代际检查，避免共享 timer 的竞态
				preview_generation = preview_generation + 1
				local gen = preview_generation
				vim.defer_fn(function()
					if gen == preview_generation then
						Engine.preview(t)
					end
				end, 50)

				return ("%s\nid: %s\nmauve: %s\nbase: %s"):format(t.name, t.id, t.colors.mauve, t.colors.base)
			end,
			fn_selected = function(selected)
				-- 取消所有待定的预览，避免选择后又被旧 timer 覆盖
				preview_generation = preview_generation + 1
				for _, n in ipairs(selected or {}) do
					local t = by_name[n]
					if t then
						return M.apply(t.id)
					end
				end
				local orig = Loader.load(orig_id)
				if orig then
					Engine.preview(orig)
				end
			end,
		}
	)
end

function UI.register_keymaps()
	vim.keymap.set("n", "<leader>tm", UI.open_picker, { desc = "Pick theme palette" })
end

--------------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------------
function M.apply(id)
	local theme = Loader.load(id)
	if not theme then
		vim.notify(("theme: '%s' not found or invalid"):format(id), vim.log.levels.ERROR)
		return
	end
	Engine.render(theme)
end

---Sole entry point, called from plugins/colorscheme.lua's config.
---@param plugin_opts table catppuccin opts (UI skeleton)
function M.init(plugin_opts)
	Engine.base_opts = plugin_opts or {}
	Engine.current_id = Storage.get_saved_id()

	local theme = Loader.load(Engine.current_id) or Loader.load("catppuccin")
	if theme then
		Engine.render(theme)
	else
		-- 双重 fallback 都失败，至少给用户明确提示并回退到 default
		vim.notify(
			("theme: no valid theme found (saved_id=%s), falling back to default"):format(tostring(Engine.current_id)),
			vim.log.levels.WARN
		)
		pcall(vim.cmd.colorscheme, "default")
	end

	UI.register_command()
	UI.register_autocmd()
	UI.register_keymaps()
end

---Palette of the active theme, {} before first render.
---@return table
function M.palette()
	return Engine.theme and Engine.theme.colors or {}
end

return M
