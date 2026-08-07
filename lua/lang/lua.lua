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
			local blink_cmp = require("blink.cmp")
			local capabilities = blink_cmp.get_lsp_capabilities()

			local lua_ls_opts = {
				filetypes = { "lua" },
				capabilities = capabilities,
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
			}

			opts.servers = opts.servers or {}
			opts.servers.lua_ls = lua_ls_opts

			vim.lsp.config("lua_ls", lua_ls_opts)
			vim.lsp.enable("lua_ls")
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
