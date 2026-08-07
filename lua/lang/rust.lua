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
			local blink_cmp = require("blink.cmp")
			local capabilities = blink_cmp.get_lsp_capabilities()

			local ra_opts = {
				filetypes = { "rust" },
				capabilities = capabilities,
				settings = {
					["rust-analyzer"] = {},
				},
			}

			opts.servers = opts.servers or {}
			opts.servers.rust_analyzer = ra_opts

			vim.lsp.config("rust_analyzer", ra_opts)
			vim.lsp.enable("rust_analyzer")
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
