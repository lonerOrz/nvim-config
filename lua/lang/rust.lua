return {
	-- =========================
	-- Treesitter
	-- =========================
	{
		"nvim-treesitter/nvim-treesitter",
		ft = "rust",
		opts = {
			ensure_installed = { "rust" },
		},
		opts_extend = { "ensure_installed" },
	},

	-- =========================
	-- Formatter (rustfmt via none-ls)
	-- =========================
	{
		"nvimtools/none-ls.nvim",
		ft = "rust",
		event = { "BufReadPre", "BufNewFile" },

		opts = function(_, opts)
			local null_ls = require("null-ls")

			opts.sources = vim.list_extend(opts.sources or {}, {
				null_ls.builtins.formatting.rustfmt,
			})

			return opts
		end,

		opts_extend = { "sources" },
	},
}
