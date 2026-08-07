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
