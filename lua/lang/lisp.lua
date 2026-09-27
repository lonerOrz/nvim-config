-- Tooling installation:
-- raco pkg install --auto --no-docs racket-langserver fmt syntax-color-lib compatibility-lib

return {
	-- Treesitter parser
	{
		"nvim-treesitter/nvim-treesitter",
		optional = true,
		opts = { ensure_installed = { "racket", "scheme" } },
		opts_extend = { "ensure_installed" },
	},

	-- LSP: racket-langserver
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				racket_langserver = {
					cmd = { "racket", "-l", "racket-langserver" },
					filetypes = { "racket", "scheme" },
					root_markers = { "info.rkt", ".git" },
					single_file_support = true,
				},
			},
		},
	},

	-- Formatter: raco fmt
	{
		"stevearc/conform.nvim",
		optional = true,
		opts = {
			formatters_by_ft = {
				racket = { "raco_fmt", lsp_fallback = true },
				scheme = { "raco_fmt", lsp_fallback = true },
			},
			formatters = {
				raco_fmt = {
					command = "raco",
					args = { "fmt" },
					stdin = true,
				},
			},
		},
	},

	-- Interactive Lisp Evaluator
	{
		"Olical/conjure",
		ft = { "racket", "scheme" },
		lazy = true,
		init = function()
			-- 配置在行尾以虚字提示结果
			vim.g["conjure#eval#inline#render"] = true
			-- 禁用提示音
			vim.g["conjure#eval#sound"] = false
			-- 让 scheme 文件也使用 racket 客户端，不再寻找 mit-scheme
			vim.g["conjure#filetype#scheme"] = "conjure.client.racket.stdio"
			-- 关闭烦人的 HUD 临时悬浮窗
			vim.g["conjure#log#hud#enabled"] = false
			-- repl 详情分屏
			vim.g["conjure#log#botright"] = true
			vim.g["conjure#log#split"] = "horizontal"
			vim.g["conjure#log#wrap"] = true
			-- Conjure 默认只认 racket=.rkt、scheme=.scm/.ss
			vim.g["conjure#filetype_suffixes#racket"] = { "rkt", "rktd", "rktl", "scrbl" }
			vim.g["conjure#filetype_suffixes#scheme"] = { "scm", "ss", "sld", "sps", "sls" }
			-- 光标进入 REPL 日志窗口时，按 q 直接关闭分屏
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
			-- 保存后重新 ,enter 当前文件，把最新定义加载进常驻 REPL。
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
				callback = function(args)
					vim.api.nvim_buf_call(args.buf, function()
						pcall(function()
							require("conjure.client").call("enter")
						end)
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
