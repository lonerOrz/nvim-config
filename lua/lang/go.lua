return {
	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		optional = true,
		opts = { ensure_installed = { "go", "gomod", "gowork", "gotmpl" } },
		opts_extend = { "ensure_installed" },
	},
	-- Mason
	{
		"mason-org/mason.nvim",
		optional = true,
		opts = { ensure_installed = { "gopls", "gofumpt", "goimports" } },
		opts_extend = { "ensure_installed" },
	},
	-- LSP
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				gopls = {},
			},
		},
	},
	-- Formatter
	{
		"stevearc/conform.nvim",
		optional = true,
		opts = {
			formatters_by_ft = {
				go = { "goimports", "gofumpt" },
			},
		},
	},
}
