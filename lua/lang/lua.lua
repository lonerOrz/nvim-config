return {
	-- Treesitter Parser
	{
		"nvim-treesitter/nvim-treesitter",
		optional = true,
		opts = {
			ensure_installed = { "lua" },
		},
		opts_extend = { "ensure_installed" },
	},

	-- Mason Packages (LSP & Formatter binaries)
	{
		"mason-org/mason.nvim",
		optional = true,
		opts = {
			ensure_installed = {
				"lua-language-server",
				"stylua",
			},
		},
		opts_extend = { "ensure_installed" },
	},

	-- LSP Server Configuration
	{
		"neovim/nvim-lspconfig",
		ft = "lua",
		opts = function(_, opts)
			opts.servers.lua_ls = vim.tbl_deep_extend("force", opts.servers.lua_ls or {}, {
				filetypes = { "lua" },
				settings = {
					Lua = {
						completion = {
							callSnippet = "Replace",
						},
						diagnostics = {
							globals = { "vim" },
						},
					},
				},
			})
		end,
	},

	-- Formatter
	{
		"stevearc/conform.nvim",
		optional = true,
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
			},
		},
	},

	-- LazyDev Integration (Neovim Lua API)
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},
}
