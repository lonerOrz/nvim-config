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
			opts.servers.zls = vim.tbl_deep_extend("force", opts.servers.zls or {}, {
				filetypes = { "zig" },
			})
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
