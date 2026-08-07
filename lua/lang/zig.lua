return {
	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		optional = true,
		opts = { ensure_installed = { "zig" } },
		opts_extend = { "ensure_installed" },
	},
	-- Mason
	{
		"mason-org/mason.nvim",
		optional = true,
		opts = { ensure_installed = { "zls" } },
		opts_extend = { "ensure_installed" },
	},
	-- LSP
	{
		"neovim/nvim-lspconfig",
		ft = "zig",
		opts = function(_, opts)
			local blink_cmp = require("blink.cmp")
			local capabilities = blink_cmp.get_lsp_capabilities()

			local zls_opts = {
				filetypes = { "zig" },
				capabilities = capabilities,
			}

			opts.servers = opts.servers or {}
			opts.servers.zls = zls_opts

			vim.lsp.config("zls", zls_opts)
			vim.lsp.enable("zls")
		end,
	},
	-- Formatter (Zig uses built-in zigfmt via ZLS or CLI)
	{
		"stevearc/conform.nvim",
		optional = true,
		opts = {
			formatters_by_ft = {
				zig = { "zigfmt" },
			},
		},
	},
}
