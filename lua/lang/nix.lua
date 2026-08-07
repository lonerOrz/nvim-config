return {
	-- Treesitter Parser
	{
		"nvim-treesitter/nvim-treesitter",
		optional = true,
		opts = {
			ensure_installed = { "nix" },
		},
		opts_extend = { "ensure_installed" },
	},

	-- LSP Server Configuration
	{
		"neovim/nvim-lspconfig",
		ft = "nix",
		opts = function(_, opts)
			local blink_cmp = require("blink.cmp")
			local capabilities = blink_cmp.get_lsp_capabilities()

			local nixd_opts = {
				cmd = { "nixd", "--inlay-hints", "--semantic-tokens" },
				root_markers = { "flake.nix", ".git" },
				filetypes = { "nix" },
				capabilities = capabilities,
				on_attach = function()
					vim.lsp.inlay_hint.enable(true)
				end,
				settings = {
					nixd = {
						nixpkgs = {
							expr = "import (builtins.getFlake(toString ./.)).inputs.nixpkgs { }",
						},
						formatting = { command = { "nixfmt" } },
						options = {
							nixos = {
								expr = "(builtins.getFlake (toString ./.)).nixosConfigurations.loneros.options",
							},
						},
					},
				},
			}

			opts.servers = opts.servers or {}
			opts.servers.nixd = nixd_opts

			vim.lsp.config("nixd", nixd_opts)
			vim.lsp.enable("nixd")
		end,
	},

	-- Formatter
	{
		"stevearc/conform.nvim",
		optional = true,
		opts = {
			formatters_by_ft = {
				nix = { "nixfmt" },
			},
		},
	},
}
