local M = {}

--------------------------------------------------------------------------------
-- Storage Layer
--------------------------------------------------------------------------------
local Storage = {}
Storage.DIR = vim.fn.stdpath("config") .. "/lua/theme/themes"
Storage.FILE = vim.fn.stdpath("state") .. "/theme.state"

function Storage.get_saved_id()
	local ok, lines = pcall(vim.fn.readfile, Storage.FILE)
	return (ok and lines[1] and lines[1] ~= "") and lines[1] or "catppuccin"
end

function Storage.save_id(id)
	pcall(vim.fn.writefile, { id }, Storage.FILE)
end

--------------------------------------------------------------------------------
-- Loader Layer
--------------------------------------------------------------------------------
local Loader = {}

function Loader.load(id)
	package.loaded["theme.themes." .. id] = nil
	local ok, mod = pcall(require, "theme.themes." .. id)
	if not ok or type(mod) ~= "table" or not mod.colors then
		return nil
	end
	return { id = id, name = mod.name or id, colors = mod.colors }
end

function Loader.scan_all()
	local themes = {}
	for _, file in ipairs(vim.fn.glob(Storage.DIR .. "/*.lua", false, true)) do
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
	Engine.current_id = theme.id
	Engine.theme = theme

	local final_opts = vim.tbl_deep_extend("force", Engine.base_opts, {
		color_overrides = { all = theme.colors },
	})

	require("catppuccin").setup(final_opts)
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
		pattern = Storage.DIR .. "/*.lua",
		callback = function(args)
			local id = vim.fs.basename(args.file):gsub("%.lua$", "")
			if (Engine.current_id or Storage.get_saved_id()) == id then
				M.apply(id)
			end
		end,
	})
end

function UI.open_picker()
	local themes = Loader.scan_all()
	-- ponytail: fzf cursor always starts at row 1, so put current theme first
	local cur = Engine.current_id or Storage.get_saved_id()
	for i, d in ipairs(themes) do
		if d.id == cur then
			table.remove(themes, i)
			table.insert(themes, 1, d)
			break
		end
	end
	local ok, fzf = pcall(require, "fzf-lua")
	if not ok then
		return vim.ui.select(themes, {
			prompt = "Select Colorscheme:",
			format_item = function(d)
				return ("%-20s (%s)"):format(d.name, d.id)
			end,
		}, function(selected)
			if selected then
				M.apply(selected.id)
			end
		end)
	end

	local orig_id = Engine.current_id or Storage.get_saved_id()
	local by_name = function(n)
		return vim.tbl_filter(function(d)
			return d.name == n
		end, themes)[1]
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
				local t = items and by_name(items[1])
				if not t then
					return ""
				end
				Engine.preview(t)
				return ("%s\nid: %s\nmauve: %s\nbase: %s"):format(t.name, t.id, t.colors.mauve, t.colors.base)
			end,
			fn_selected = function(selected)
				for _, n in ipairs(selected or {}) do
					local t = by_name(n)
					if t then
						return M.apply(t.id)
					end
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
