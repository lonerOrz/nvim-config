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
		ft = "python",
		opts = function(_, opts)
			local blink_cmp = require("blink.cmp")
			local capabilities = blink_cmp.get_lsp_capabilities()

			local pyright_opts = {
				filetypes = { "python" },
				capabilities = capabilities,
			}

			opts.servers = opts.servers or {}
			opts.servers.pyright = pyright_opts

			vim.lsp.config("pyright", pyright_opts)
			vim.lsp.enable("pyright")
		end,
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
