-- Pre Tools
--   Racket: raco pkg install --auto --no-docs racket-langserver fmt syntax-color-lib compatibility-lib
--   Guile:  guile, guile-lsp-server, schemat on $PATH.

local FILETYPES = {
	racket = { "rkt", "rktd", "rktl", "scrbl" },
	scheme = { "scm", "ss", "sld", "sps", "sls" },
}

-- Register only missing extensions without explicitly loading vim.filetype.
do
	local extensions = {}

	for filetype, suffixes in pairs(FILETYPES) do
		for _, suffix in ipairs(suffixes) do
			extensions[suffix] = filetype
		end
	end

	local patterns = {}

	for ext in pairs(extensions) do
		patterns[#patterns + 1] = "*." .. ext
	end

	vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
		group = vim.api.nvim_create_augroup("LispFiletype", { clear = true }),
		desc = "Extra Scheme/Racket extensions missing from nvim's filetype.lua",
		pattern = patterns,
		callback = function(args)
			if vim.bo[args.buf].filetype ~= "" then
				return
			end

			local ext = vim.fn.fnamemodify(args.match, ":e")
			local filetype = extensions[ext]

			if filetype then
				vim.bo[args.buf].filetype = filetype
			end
		end,
	})
end

-- These options affect Guile only, never the Racket REPL.
local GUILE_INIT = {
	"(use-modules (system repl common))",
	"(repl-default-option-set! 'on-error 'report)",
	"(use-modules ((system repl repl) #:select (%inhibit-welcome-message)))",
	"(%inhibit-welcome-message #t)",
}

local function guile_command()
	local state_dir = vim.fn.stdpath("state")
	local init = vim.fs.joinpath(state_dir, "conjure-guile-init.scm")
	local expected = table.concat(GUILE_INIT, "\n")

	-- Conjure's Scheme completion module expects command to be a string.
	-- Its command parser does not safely support paths containing whitespace.
	if init:find("%s") then
		vim.notify(
			("Guile init path contains whitespace; using default REPL settings: %s")
				:format(init),
			vim.log.levels.WARN
		)

		return "guile -q --no-auto-compile --"
	end

	local ok_read, current = pcall(vim.fn.readfile, init)

	if not ok_read or table.concat(current, "\n") ~= expected then
		vim.fn.mkdir(state_dir, "p")

		if vim.fn.isdirectory(state_dir) == 0 then
			vim.notify(
				("Could not create Neovim state directory: %s"):format(state_dir),
				vim.log.levels.ERROR
			)

			return "guile -q --no-auto-compile --"
		end

		local ok_write, rc = pcall(vim.fn.writefile, GUILE_INIT, init)

		if not ok_write or rc ~= 0 then
			vim.notify(
				("Could not write Guile init file: %s"):format(init),
				vim.log.levels.ERROR
			)

			return "guile -q --no-auto-compile --"
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

		if name == "" or name:match("conjure%-log") then
			return
		end

		on_dir(vim.fs.root(bufnr, markers) or vim.fs.dirname(name))
	end
end

local function conjure_vars()
	return {
		["conjure#client#scheme#stdio#command"] = guile_command(),
		["conjure#client#scheme#stdio#prompt_pattern"] =
			"%s*scheme@%b()%s*%[?%d*%]?%s*> ",
		["conjure#client#scheme#stdio#value_prefix_pattern"] = "^%$%d+ = ",

		["conjure#client#racket#stdio#auto_enter"] = false,

		-- Conjure's stdio Scheme/Racket clients do not implement def-str.
		-- Use the LSP mapping configured below for gd instead.
		["conjure#mapping#def_word"] = false,

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

	-- Fall back to word evaluation when no form can be extracted.
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

	-- Show feedback when an evaluation produces no value.
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

	-- Install preceding definitions before evaluating the current form.
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

		local function position_after(row, col, position)
			return row > position.row
				or (row == position.row and col > position.col)
		end

		local function position_at_or_before(row, col, position)
			return row < position.row
				or (row == position.row and col <= position.col)
		end

		local function definitions(buf, heads, after_position, boundary)
			local ok, parser = pcall(vim.treesitter.get_parser, buf)

			if not ok or not parser then
				return nil, false
			end

			local ok_parse, trees = pcall(function()
				return parser:parse()
			end)

			if not ok_parse or not trees or not trees[1] then
				return nil, false
			end

			local found = {}

			for node in trees[1]:root():iter_children() do
				local start_row, start_col, end_row, end_col = node:range()
				local head = head_of(node, buf)

				local after_previous = not after_position
					or position_after(start_row, start_col, after_position)

				local before_current = position_at_or_before(
					end_row,
					end_col,
					boundary
				)

				if after_previous and before_current and head and heads[head] then
					found[#found + 1] = vim.treesitter.get_node_text(node, buf)
				end
			end

			if #found == 0 then
				return nil, true
			end

			return table.concat(found, "\n"), true
		end

		local function form_position()
			local ok, node = pcall(ts["get-root"])

			if not ok or not node then
				return nil
			end

			local row, col = node:range()

			return {
				row = row,
				col = col,
			}
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

				if opts.origin == "file"
					or opts.origin == "buf"
					or name == ""
					or log["log-buf?"](name)
				then
					return eval_str(opts)
				end

				if not opts.code then
					return eval_str(opts)
				end

				local boundary = form_position()

				if not boundary then
					return eval_str(opts)
				end

				local tick = vim.api.nvim_buf_get_changedtick(buf)
				local previous = installed[buf]
				local previous_valid = previous and previous.tick == tick

				-- If evaluating an earlier or identical form, do not
				-- reinstall definitions that were already synchronized.
				if previous_valid
					and not position_after(boundary.row, boundary.col, previous)
				then
					return eval_str(opts)
				end

				local after_position = previous_valid and previous or nil
				local setup, parsed = definitions(
					buf,
					heads,
					after_position,
					boundary
				)

				-- Never advance the cache if parsing failed.
				if not parsed then
					return eval_str(opts)
				end

				local on_result = opts["on-result"]
				local eval_opts = vim.tbl_extend("force", {}, opts, {
					["on-result"] = function(result)
						installed[buf] = {
							tick = tick,
							row = boundary.row,
							col = boundary.col,
						}

						if on_result then
							on_result(result)
						end
					end,
				})

				if setup then
					eval_opts.code = wrap(setup, opts.code)
				end

				return eval_str(eval_opts)
			end)
		end

		-- Keep Racket and Guile clients independent.
		wrap_eval_str(racket, SETUP_FORMS.racket, function(setup, form)
			return ("(begin\n%s\n(void)\n%s)"):format(setup, form)
		end)

		wrap_eval_str(scheme, SETUP_FORMS.scheme, function(setup, form)
			return ("(begin\n%s\n(values)\n%s)"):format(setup, form)
		end)
	end
end

-- Use LSP for gd instead of Conjure's unsupported def-str feature.
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("LispLspNavigation", {
		clear = true,
	}),
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)

		if not client or not client.server_capabilities.definitionProvider then
			return
		end

		vim.keymap.set("n", "gd", vim.lsp.buf.definition, {
			buffer = args.buf,
			silent = true,
			desc = "LSP: Go to definition",
		})
	end,
})

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
					cmd = { "racket", "--lib", "racket-langserver" },
					filetypes = { "racket" },
					root_dir = no_conjure_log_root({ "info.rkt", ".git" }),
				},

				guile_ls = {
					cmd = { "guile-lsp-server" },
					-- This matches the "scheme" filetype used by this config.
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
