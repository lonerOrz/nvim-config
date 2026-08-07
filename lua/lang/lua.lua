return {
	-- Treesitter Support
	{
		"nvim-treesitter/nvim-treesitter",
		optional = true,
		opts = {
			ensure_installed = { "lua" },
		},
		opts_extend = { "ensure_installed" },
	},

	-- LSP Setup
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

	-- Mason Packages
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

	-- Formatter
	{
		"nvimtools/none-ls.nvim",
		opts = {
			sources = {
				require("null-ls").builtins.formatting.stylua,
			},
		},
		opts_extend = { "sources" },
	},

	-- LazyDev API Completion
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
