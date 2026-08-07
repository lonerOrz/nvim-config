return {
	-- Treesitter Support
	{
		"nvim-treesitter/nvim-treesitter",
		ft = "rust",
		opts = {
			ensure_installed = { "rust" },
		},
		opts_extend = { "ensure_installed" },
	},

	-- LSP Setup
	{
		"neovim/nvim-lspconfig",
		ft = "rust",
		opts = function(_, opts)
			opts.servers.rust_analyzer = vim.tbl_deep_extend("force", opts.servers.rust_analyzer or {}, {
				filetypes = { "rust" },
				settings = {
					["rust-analyzer"] = {},
				},
			})
		end,
	},
}
