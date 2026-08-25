return {
	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		optional = true,
		opts = { ensure_installed = { "python" } },
		opts_extend = { "ensure_installed" },
	},
	-- Mason
	{
		"mason-org/mason.nvim",
		optional = true,
		opts = { ensure_installed = { "pyright", "black" } },
		opts_extend = { "ensure_installed" },
	},
	-- LSP
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				pyright = {},
			},
		},
	},
	-- Formatter
	{
		"stevearc/conform.nvim",
		optional = true,
		opts = {
			formatters_by_ft = {
				python = { "black" },
			},
		},
	},
}
