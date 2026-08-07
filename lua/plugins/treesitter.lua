return {
	-- Treesitter Parser Setup
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
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
				"rust",
			},
		},

		config = function(_, opts)
			local ts = require("nvim-treesitter")

			ts.setup({
				install_dir = vim.fn.stdpath("data") .. "/site",
			})

			vim.schedule(function()
				ts.install(opts.ensure_installed)
			end)

			local group = vim.api.nvim_create_augroup("UserTreesitter", { clear = true })

			vim.api.nvim_create_autocmd("FileType", {
				group = group,
				callback = function(args)
					local bufnr = args.buf
					local ft = vim.bo[bufnr].filetype

					if ft == "" or ft == "help" or vim.bo[bufnr].buftype ~= "" then
						return
					end

					pcall(vim.treesitter.start, bufnr)

					vim.schedule(function()
						if not vim.api.nvim_buf_is_valid(bufnr) then
							return
						end

						for _, win in ipairs(vim.api.nvim_list_wins()) do
							if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == bufnr then
								vim.wo[win].foldmethod = "expr"
								vim.wo[win].foldexpr = "v:lua.vim.treesitter.foldexpr()"
							end
						end
					end)
				end,
			})
		end,
	},
}
