return {
	-- Treesitter Parser
	{
		"nvim-treesitter/nvim-treesitter",
		optional = true,
		opts = {
			ensure_installed = { "rust" },
		},
		opts_extend = { "ensure_installed" },
	},

	-- Mason Packages
	{
		"mason-org/mason.nvim",
		optional = true,
		opts = {
			ensure_installed = { "rust-analyzer" },
		},
		opts_extend = { "ensure_installed" },
	},

	-- LSP Server Configuration
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				rust_analyzer = {
					settings = {
						["rust-analyzer"] = {},
					},
				},
			},
		},
	},

	-- Formatter (Rust uses LSP native formatting via rustfmt)
	{
		"stevearc/conform.nvim",
		optional = true,
		opts = {
			formatters_by_ft = {
				rust = { "rustfmt" },
			},
		},
	},
}
