return {
	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		optional = true,
		opts = { ensure_installed = { "c", "cpp", "cmake", "make" } },
		opts_extend = { "ensure_installed" },
	},
	-- Mason
	{
		"mason-org/mason.nvim",
		optional = true,
		opts = { ensure_installed = { "clangd", "clang-format" } },
		opts_extend = { "ensure_installed" },
	},
	-- LSP
	{
		"neovim/nvim-lspconfig",
		ft = { "c", "cpp", "objc", "objcpp" },
		opts = function(_, opts)
			opts.servers.clangd = vim.tbl_deep_extend("force", opts.servers.clangd or {}, {
				filetypes = { "c", "cpp", "objc", "objcpp" },
			})
		end,
	},
	-- Formatter
	{
		"stevearc/conform.nvim",
		optional = true,
		opts = {
			formatters_by_ft = {
				c = { "clang-format" },
				cpp = { "clang-format" },
			},
		},
	},
}
