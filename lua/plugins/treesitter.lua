return {
	-- Treesitter Parser Setup
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		event = { "BufReadPre", "BufNewFile" },
		build = ":TSUpdate",

		opts = {
			-- Generic/misc parsers only; language-specific ones live in lang/*.lua
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

					local ok = pcall(vim.treesitter.start, bufnr)
					if not ok then
						return
					end

					vim.wo[0][0].foldmethod = "expr"
					vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
				end,
			})
		end,
	},
}
