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
		ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
		opts = function(_, opts)
			local blink_cmp = require("blink.cmp")
			local capabilities = blink_cmp.get_lsp_capabilities()

			local ts_ls_opts = {
				filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
				capabilities = capabilities,
			}

			opts.servers = opts.servers or {}
			opts.servers.ts_ls = ts_ls_opts

			vim.lsp.config("ts_ls", ts_ls_opts)
			vim.lsp.enable("ts_ls")
		end,
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
