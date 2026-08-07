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
		ft = { "go", "gomod" },
		opts = function(_, opts)
			opts.servers.gopls = vim.tbl_deep_extend("force", opts.servers.gopls or {}, {
				filetypes = { "go", "gomod" },
			})
		end,
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
