return {
	{
		"nvim-treesitter/nvim-treesitter",
		ft = "rust",
		opts = {
			ensure_installed = { "rust" },
		},
		opts_extend = { "ensure_installed" },
	},

	{
		"neovim/nvim-lspconfig",
		ft = "rust",
		opts = function(_, opts)
			opts.servers.rust_analyzer = vim.tbl_deep_extend("force", opts.servers.rust_analyzer or {}, {
				filetypes = { "rust" },
				-- Rust formatting is provided explicitly by rust-analyzer.
				settings = {
					["rust-analyzer"] = {},
				},
			})
		end,
	},
}
