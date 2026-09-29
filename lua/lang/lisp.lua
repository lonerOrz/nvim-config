-- Tooling
--   Racket: raco pkg install --auto --no-docs racket-langserver fmt syntax-color-lib compatibility-lib
--   Guile:  guile, guile-lsp-server, schemat on $PATH.

-- File extensions; drives filetype detection and Conjure client selection.
local FILETYPES = {
	racket = { "rkt", "rktd", "rktl", "scrbl" },
	scheme = { "scm", "ss", "sld", "sps", "sls" },
}

do
	local extensions = {}
	for filetype, suffixes in pairs(FILETYPES) do
		for _, suffix in ipairs(suffixes) do
			extensions[suffix] = filetype
		end
	end
	vim.filetype.add({ extension = extensions })
end

-- Guile REPL init (loaded via -l): backtrace on error; hide welcome banner.
local GUILE_INIT = {
	"(use-modules (system repl common))",
	"(repl-default-option-set! 'on-error 'backtrace)",
	"(use-modules ((system repl repl) #:select (%inhibit-welcome-message)))",
	"(%inhibit-welcome-message #t)",
}

-- Build Guile command; init file is written once and loaded with -l.
local function guile_command()
	local init = vim.fs.joinpath(vim.fn.stdpath("state"), "conjure-guile-init.scm")
	local ok, rc = pcall(vim.fn.writefile, GUILE_INIT, init)
	-- -q: ignore ~/.guile; --no-auto-compile: suppress compile notice.
	if ok and rc == 0 then
		return ("guile -q --no-auto-compile -l %s --"):format(init)
	end
	return "guile --"
end

-- Dynamic assignment to avoid lua-language-server duplicate-field warnings.
local function assign(target, key, value)
	target[key] = value
end

-- Conjure options (applied before plugin load).
local CONJURE = {
	["conjure#client#scheme#stdio#command"] = guile_command(),
	-- Guile prompt; leading %s* consumes the trailing newline after each value.
	["conjure#client#scheme#stdio#prompt_pattern"] = "%s*scheme@%b()%s*%[?%d*%]?%s*> ",
	["conjure#client#scheme#stdio#value_prefix_pattern"] = "^%$%d+ = ",
	["conjure#client#racket#stdio#auto_enter"] = true,
	["conjure#eval#inline_results"] = true,
	["conjure#eval#sound"] = false,
	["conjure#log#hud#enabled"] = false,
	["conjure#log#botright"] = true,
	["conjure#log#split"] = "horizontal",
	["conjure#log#wrap"] = true,
	["conjure#filetype_suffixes#racket"] = FILETYPES.racket,
	["conjure#filetype_suffixes#scheme"] = FILETYPES.scheme,
}

return {
	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		optional = true,
		opts = { ensure_installed = { "racket", "scheme" } },
		opts_extend = { "ensure_installed" },
	},

	-- LSP
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				racket_langserver = {
					cmd = { "racket", "-l", "racket-langserver" },
					filetypes = { "racket" },
					root_markers = { "info.rkt", ".git" },
					single_file_support = true,
				},
				-- Prefer our scheme filetype over the default scheme.guile.
				guile_ls = {
					cmd = { "guile-lsp-server" },
					filetypes = { "scheme" },
					root_markers = { "guix.scm", ".git" },
					single_file_support = true,
				},
			},
		},
	},

	-- Formatting
	{
		"stevearc/conform.nvim",
		optional = true,
		opts = {
			formatters_by_ft = {
				racket = { "raco_fmt" },
				scheme = { "schemat" },
			},
			formatters = {
				raco_fmt = { command = "raco", args = { "fmt" }, stdin = true },
				schemat = { command = "schemat", stdin = true },
			},
		},
	},

	-- Interactive evaluation
	{
		"Olical/conjure",
		ft = { "racket", "scheme" },
		lazy = true,
		init = function()
			for key, value in pairs(CONJURE) do
				vim.g[key] = value
			end
			-- q closes the REPL log split.
			vim.api.nvim_create_autocmd("BufWinEnter", {
				pattern = "*conjure-log*",
				callback = function(ev)
					vim.keymap.set("n", "q", "<CMD>close<CR>", {
						buffer = ev.buf,
						silent = true,
						nowait = true,
						desc = "Close REPL split",
					})
				end,
			})
		end,
		-- Runtime wrappers for client behaviour not exposed by documented options.
		config = function()
			local eval = require("conjure.eval")
			local scheme = require("conjure.client.scheme.stdio")
			local racket = require("conjure.client.racket.stdio")

			-- 1. Fallback: eval word when no form is present.
			local current_form = eval["current-form"]
			assign(eval, "current-form", function(opts)
				local ok, form = pcall(function()
					return require("conjure.extract").form({})
				end)
				if ok and form and form.content and form.content ~= "" then
					return current_form(opts)
				end
				return eval.word()
			end)

			-- 2. Drop stray "; (out) " lines produced by value-less evaluations.
			local format_msg = scheme["format-msg"]
			assign(scheme, "format-msg", function(msg)
				return vim.tbl_filter(function(line)
					return line ~= scheme["comment-prefix"] .. "(out) "
				end, format_msg(msg))
			end)

			-- 3. Confirm empty results ("loaded"/"defined"); respect silent mode.
			local eval_str = scheme["eval-str"]
			assign(scheme, "eval-str", function(opts)
				local on_result = opts["on-result"]
				if opts.silent then
					opts["on-result"] = on_result or function() end
				else
					opts["on-result"] = function(result)
						if result == nil or result == "" then
							result = opts.origin == "file" and "loaded" or "defined"
							require("conjure.log").append({ result })
						end
						if on_result then
							on_result(result)
						end
					end
				end
				return eval_str(opts)
			end)

			-- 4. Load current file into Guile REPL; (values) suppresses last value.
			local function load_current_file(silent)
				local file = vim.fn.expand("%:p")
				if file ~= "" and vim.fn.filereadable(file) == 1 then
					scheme["eval-str"]({
						code = ("(begin (load %q) (values))"):format(file),
						origin = "file",
						silent = silent,
					})
				end
			end

			-- Track REPL state (client state is private).
			local scheme_up = false
			local scheme_start = scheme["start"]
			local scheme_stop = scheme["stop"]
			assign(scheme, "start", function()
				scheme_up = true
				scheme_start()
				load_current_file(false)
			end)
			assign(scheme, "stop", function()
				scheme_up = false
				return scheme_stop()
			end)

			local racket_up = false
			local racket_start = racket["start"]
			local racket_stop = racket["stop"]
			assign(racket, "start", function()
				racket_up = true
				return racket_start()
			end)
			assign(racket, "stop", function()
				racket_up = false
				return racket_stop()
			end)

			-- 5. Silent reload on save.
			vim.api.nvim_create_autocmd("BufWritePost", {
				pattern = {
					"*.rkt",
					"*.rktd",
					"*.rktl",
					"*.scrbl",
					"*.scm",
					"*.ss",
					"*.sld",
					"*.sps",
					"*.sls",
				},
				callback = function(ev)
					vim.api.nvim_buf_call(ev.buf, function()
						if vim.bo.filetype == "racket" and racket_up then
							racket["enter"]()
						elseif vim.bo.filetype == "scheme" and scheme_up then
							load_current_file(true)
						end
					end)
				end,
			})
		end,
		keys = {
			-- <leader>r : Eval & REPL
			{
				"<leader>rl",
				function()
					local cur_win = vim.api.nvim_get_current_win()
					for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
						local buf = vim.api.nvim_win_get_buf(win)
						local name = vim.api.nvim_buf_get_name(buf)
						if name:match("conjure%-log") then
							vim.api.nvim_win_close(win, true)
							return
						end
					end
					vim.cmd("ConjureLogSplit")
					vim.api.nvim_set_current_win(cur_win)
				end,
				desc = "Toggle REPL",
			},
			{ "<leader>rr", "<CMD>ConjureLogResetSoft<CR>", desc = "Reset REPL buffer" },
		},
	},
}
