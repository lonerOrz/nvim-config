return {
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",
		opts = {
			ensure_installed = {
				"bash",
				"c",
				"cmake",
				"css",
				"dockerfile",
				"elixir",
				"go",
				"heex",
				"html",
				"ini",
				"javascript",
				"json",
				"just",
				"latex",
				"make",
				"markdown",
				"nix",
				"python",
				"query",
				"regex",
				"scss",
				"sql",
				"svelte",
				"toml",
				"tsx",
				"typescript",
				"typst",
				"vim",
				"vimdoc",
				"yaml",
			},
			sync_install = false,
			auto_install = true,
		},
		config = function(_, opts)
			local ts = require("nvim-treesitter.configs")

			-- use nvim-treesitter.configs.setup() 启用模块
			ts.setup({
				ensure_installed = opts.ensure_installed,
				sync_install = opts.sync_install,
				auto_install = opts.auto_install,
				highlight = { enable = true },
				indent = { enable = true },
			})

			-- custom fold
			local group = vim.api.nvim_create_augroup("UserTreesitter", { clear = true })
			vim.api.nvim_create_autocmd("FileType", {
				group = group,
				callback = function(args)
					local ft = vim.bo[args.buf].filetype

					if ft == "" or ft == "help" then
						return
					end

					vim.opt_local.foldmethod = "expr"
					vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
				end,
			})
		end,
	},
}
