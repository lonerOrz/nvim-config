-- Pre Tools
--   Racket: raco pkg install --auto --no-docs racket-langserver fmt syntax-color-lib compatibility-lib
--   Guile:  guile, guile-lsp-server, schemat on $PATH.

local FILETYPES = {
	racket = { "rkt", "rktd", "rktl", "scrbl" },
	scheme = { "scm", "ss", "sld", "sps", "sls" },
}

-- Register only missing extensions to avoid loading vim.filetype during startup.
do
	local extensions = {}

	for filetype, suffixes in pairs(FILETYPES) do
		for _, suffix in ipairs(suffixes) do
			extensions[suffix] = filetype
		end
	end

	vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
		group = vim.api.nvim_create_augroup("LispFiletype", { clear = true }),
		desc = "Extra Scheme/Racket extensions missing from nvim's filetype.lua",
		callback = function(args)
			if vim.bo[args.buf].filetype ~= "" then
				return
			end

			local ft = extensions[vim.fn.fnamemodify(args.match, ":e")]

			if ft then
				vim.bo[args.buf].filetype = ft
			end
		end,
		pattern = (function()
			local patterns = {}
			for ext in pairs(extensions) do
				patterns[#patterns + 1] = "*." .. ext
			end
			return patterns
		end)(),
	})
end

local GUILE_INIT = {
	"(use-modules (system repl common))",
	"(repl-default-option-set! 'on-error 'backtrace)",
	"(use-modules ((system repl repl) #:select (%inhibit-welcome-message)))",
	"(%inhibit-welcome-message #t)",
}

local function guile_command()
	local init = vim.fs.joinpath(vim.fn.stdpath("state"), "conjure-guile-init.scm")
	local ok, current = pcall(vim.fn.readfile, init)

	if not ok or table.concat(current, "\n") ~= table.concat(GUILE_INIT, "\n") then
		local wrote, rc = pcall(vim.fn.writefile, GUILE_INIT, init)

		if not (wrote and rc == 0) then
			return "guile --"
		end
	end

	return ("guile -q --no-auto-compile -l %s --"):format(init)
end

local function assign(target, key, value)
	target[key] = value
end

local function no_conjure_log_root(markers)
	return function(bufnr, on_dir)
		local name = vim.api.nvim_buf_get_name(bufnr)

		if name:match("conjure%-log") then
			return
		end

		on_dir(vim.fs.root(bufnr, markers) or vim.fs.dirname(name))
	end
end

-- Built lazily: guile_command() writes conjure-guile-init.scm to disk, which
-- must not happen on every startup for a buffer that may never be Scheme.
local function conjure_vars()
	return {
		["conjure#client#scheme#stdio#command"] = guile_command(),
		["conjure#client#scheme#stdio#prompt_pattern"] = "%s*scheme@%b()%s*%[?%d*%]?%s*> ",
		["conjure#client#scheme#stdio#value_prefix_pattern"] = "^%$%d+ = ",
		["conjure#client#racket#stdio#auto_enter"] = false,

		["conjure#eval#inline_results"] = true,
		["conjure#eval#sound"] = false,

		["conjure#log#hud#enabled"] = false,
		["conjure#log#botright"] = true,
		["conjure#log#split#height"] = 0.3,
		["conjure#log#wrap"] = true,

		["conjure#filetype_suffixes#racket"] = FILETYPES.racket,
		["conjure#filetype_suffixes#scheme"] = FILETYPES.scheme,
	}
end

local function setup_conjure()
	local eval = require("conjure.eval")
	local extract = require("conjure.extract")
	local log = require("conjure.log")
	local ts = require("conjure.tree-sitter")
	local scheme = require("conjure.client.scheme.stdio")
	local racket = require("conjure.client.racket.stdio")

	-- Fallback to word evaluation.
	do
		local current_form = eval["current-form"]

		assign(eval, "current-form", function(opts)
			local ok, form = pcall(extract.form, {})

			if ok and form and form.content and form.content ~= "" then
				return current_form(opts)
			end

			return eval.word()
		end)
	end

	-- Hide empty Scheme output.
	do
		local format_msg = scheme["format-msg"]

		assign(scheme, "format-msg", function(msg)
			local lines = format_msg(msg)
			local empty_output = scheme["comment-prefix"] .. "(out) "

			return vim.tbl_filter(function(line)
				return line ~= empty_output
			end, lines)
		end)
	end

	-- Show feedback for value-less evaluations.
	do
		local eval_str = scheme["eval-str"]

		assign(scheme, "eval-str", function(opts)
			local on_result = opts["on-result"]

			if opts.silent then
				opts["on-result"] = on_result or function() end
			else
				opts["on-result"] = function(result)
					if result == nil or result == "" then
						result = opts.origin == "file" and "loaded" or "defined"
						log.append({ result })
					end

					if on_result then
						on_result(result)
					end
				end
			end

			return eval_str(opts)
		end)
	end

	-- Install preceding definitions from the current buffer before eval.
	do
		local SETUP_FORMS = {
			racket = {
				["define"] = true,
				["define-syntax"] = true,
				["define-syntax-rule"] = true,
				["define-values"] = true,
				["define-record-type"] = true,
				["define-struct"] = true,
				["define-match-expander"] = true,
				["define-runtime-path"] = true,
				["define-sequence-syntax"] = true,
				["struct"] = true,
				["require"] = true,
			},

			scheme = {
				["define"] = true,
				["define*"] = true,
				["define-syntax"] = true,
				["define-syntax-rule"] = true,
				["define-values"] = true,
				["define-record-type"] = true,
				["define-public"] = true,
				["define-constant"] = true,
				["define-once"] = true,
				["define-module"] = true,
				["use-modules"] = true,
				["use-syntax"] = true,
				["import"] = true,
			},
		}

		local function head_of(node, buf)
			if node:type() ~= "list" then
				return nil
			end

			local symbol = node:child(1)

			if not symbol then
				return nil
			end

			return vim.treesitter.get_node_text(symbol, buf)
		end

		local function definitions(buf, heads, from_row, boundary)
			local ok, parser = pcall(vim.treesitter.get_parser, buf)

			if not ok or not parser then
				return nil
			end

			local trees = parser:parse()

			if not trees or not trees[1] then
				return nil
			end

			local found = {}

			for node in trees[1]:root():iter_children() do
				local _, _, last_row = node:range()
				local head = head_of(node, buf)

				if last_row >= from_row and last_row < boundary and head and heads[head] then
					found[#found + 1] = vim.treesitter.get_node_text(node, buf)
				end
			end

			if #found == 0 then
				return nil
			end

			return table.concat(found, "\n")
		end

		local function form_row()
			local ok, node = pcall(ts["get-root"])

			if ok and node then
				return select(1, node:range())
			end

			return vim.fn.line(".") - 1
		end

		local function wrap_eval_str(client, heads, wrap)
			local eval_str = client["eval-str"]
			local start = client.start
			local stop = client.stop
			local installed = {}

			assign(client, "start", function(...)
				installed = {}
				return start(...)
			end)

			assign(client, "stop", function(...)
				installed = {}
				return stop(...)
			end)

			assign(client, "eval-str", function(opts)
				local buf = vim.api.nvim_get_current_buf()
				local name = vim.api.nvim_buf_get_name(buf)

				if opts.origin == "file" or opts.origin == "buf" or name == "" or log["log-buf?"](name) then
					return eval_str(opts)
				end

				local boundary = form_row()
				local tick = vim.api.nvim_buf_get_changedtick(buf)
				local previous = installed[buf]
				local from_row = 0

				if previous and previous.tick == tick then
					if previous.row >= boundary then
						return eval_str(opts)
					end

					from_row = previous.row
				end

				local setup = opts.code and definitions(buf, heads, from_row, boundary)

				if not setup then
					installed[buf] = {
						tick = tick,
						row = boundary,
					}

					return eval_str(opts)
				end

				local on_result = opts["on-result"]

				return eval_str(vim.tbl_extend("force", {}, opts, {
					code = wrap(setup, opts.code),
					["on-result"] = function(result)
						installed[buf] = {
							tick = tick,
							row = boundary,
						}

						if on_result then
							on_result(result)
						end
					end,
				}))
			end)
		end

		wrap_eval_str(racket, SETUP_FORMS.racket, function(setup, form)
			return ("(begin\n%s\n(void)\n%s)"):format(setup, form)
		end)

		wrap_eval_str(scheme, SETUP_FORMS.scheme, function(setup, form)
			return ("(begin\n%s\n(values)\n%s)"):format(setup, form)
		end)
	end
end

return {
	{
		"nvim-treesitter/nvim-treesitter",
		optional = true,
		opts = {
			ensure_installed = { "racket", "scheme" },
		},
		opts_extend = { "ensure_installed" },
	},

	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				racket_langserver = {
					cmd = { "racket", "-l", "racket-langserver" },
					filetypes = { "racket" },
					root_dir = no_conjure_log_root({ "info.rkt", ".git" }),
				},

				guile_ls = {
					cmd = { "guile-lsp-server" },
					filetypes = { "scheme" },
					root_dir = no_conjure_log_root({ "guix.scm", ".git" }),
				},
			},
		},
	},

	{
		"stevearc/conform.nvim",
		optional = true,
		opts = {
			formatters_by_ft = {
				racket = { "raco_fmt" },
				scheme = { "schemat" },
			},

			formatters = {
				raco_fmt = {
					command = "raco",
					args = { "fmt" },
					stdin = true,
				},

				schemat = {
					command = "schemat",
					stdin = true,
				},
			},
		},
	},

	{
		"Olical/conjure",
		ft = { "racket", "scheme" },
		lazy = true,

		init = function()
			for key, value in pairs(conjure_vars()) do
				vim.g[key] = value
			end

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

		config = setup_conjure,

		keys = {
			{
				"<leader>rl",
				function()
					local current_win = vim.api.nvim_get_current_win()

					for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
						local buf = vim.api.nvim_win_get_buf(win)
						local name = vim.api.nvim_buf_get_name(buf)

						if name:match("conjure%-log") then
							vim.api.nvim_win_close(win, true)
							return
						end
					end

					vim.cmd("ConjureLogSplit")
					vim.api.nvim_set_current_win(current_win)
				end,
				desc = "Toggle REPL",
			},
			{
				"<leader>rr",
				"<CMD>ConjureLogResetSoft<CR>",
				desc = "Reset REPL buffer",
			},
		},
	},
}
