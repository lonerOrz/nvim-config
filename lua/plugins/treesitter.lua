return {
	-- Treesitter Parser Setup
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		build = ":TSUpdate",

		-- main 分支不支持懒加载；用标准事件替代 LazyVim 的 LazyFile。
		-- 从命令行打开文件时立即加载（首屏高亮），
		-- 仅启动 nvim 时走 VeryLazy 延迟加载（不拖慢冷启动）。
		event = { "BufReadPost", "BufNewFile", "BufWritePre", "VeryLazy" },
		lazy = vim.fn.argc(-1) == 0,

		cmd = { "TSUpdate", "TSInstall", "TSLog", "TSUninstall" },

		opts_extend = { "ensure_installed" },

		opts = {
			ensure_installed = {
				"dockerfile",
				"elixir",
				"heex",
				"ini",
				"just",
				"latex",
				"markdown",
				"markdown_inline",
				"query",
				"regex",
				"scss",
				"sql",
				"toml",
				"typst",
				"vim",
				"vimdoc",
				"yaml",
			},
		},

		init = function(plugin)
			-- 将 queries 加入 rtp 并预加载谓词，避免其他插件因模块未加载而报错
			require("lazy.core.loader").add_to_rtp(plugin)
			-- pcall(require, "nvim-treesitter.query_predicates")

			local group = vim.api.nvim_create_augroup("UserTreesitter", { clear = true })

			vim.api.nvim_create_autocmd("FileType", {
				group = group,
				callback = function(args)
					local bufnr = args.buf
					local ft = vim.bo[bufnr].filetype

					-- 跳过特殊 buffer 如 nofile、prompt、terminal 等
					if ft == "" or ft == "help" or vim.bo[bufnr].buftype ~= "" then
						return
					end

					-- 验证 filetype 能映射到真实存在的解析器
					local lang = vim.treesitter.language.get_lang(ft)
					if not lang or not vim.treesitter.language.add(lang) then
						return
					end

					-- parser 已存在则直接启用
					if pcall(vim.treesitter.start, bufnr) then
						return
					end

					-- parser 缺失时，先安装再启用
					require("nvim-treesitter").install({ lang }, function()
						pcall(vim.treesitter.start, bufnr)
					end)
				end,
			})
		end,

		config = function(_, opts)
			local ts = require("nvim-treesitter")

			ts.setup({
				install_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "site"),
			})

			-- 异步安装，不阻塞启动
			ts.install(opts.ensure_installed)
		end,
	},
}
