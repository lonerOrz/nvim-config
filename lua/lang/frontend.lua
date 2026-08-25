return {
	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		optional = true,
		opts = { ensure_installed = { "javascript", "typescript", "tsx", "html", "css", "svelte" } },
		opts_extend = { "ensure_installed" },
	},
	-- Mason
	{
		"mason-org/mason.nvim",
		optional = true,
		opts = { ensure_installed = { "typescript-language-server", "prettier" } },
		opts_extend = { "ensure_installed" },
	},
	-- LSP
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				ts_ls = {},
			},
		},
	},
	-- Formatter
	{
		"stevearc/conform.nvim",
		optional = true,
		opts = {
			formatters_by_ft = {
				javascript = { "prettier" },
				typescript = { "prettier" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },
			},
		},
	},
}
