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
			local blink_cmp = require("blink.cmp")
			local capabilities = blink_cmp.get_lsp_capabilities()

			local gopls_opts = {
				filetypes = { "go", "gomod" },
				capabilities = capabilities,
			}

			opts.servers = opts.servers or {}
			opts.servers.gopls = gopls_opts

			vim.lsp.config("gopls", gopls_opts)
			vim.lsp.enable("gopls")
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
