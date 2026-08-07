return {
	-- Treesitter Support
	{
		"nvim-treesitter/nvim-treesitter",
		ft = "nix",
		opts = {
			ensure_installed = { "nix" },
		},
		opts_extend = { "ensure_installed" },
	},

	-- Formatter Setup
	{
		"nvimtools/none-ls.nvim",
		ft = "nix",
		opts = {
			sources = {
				{
					name = "nixfmt_rfc",
					method = require("null-ls").methods.FORMATTING,
					filetypes = { "nix" },
					generator = require("null-ls.helpers").formatter_factory({
						command = "nixfmt",
						args = {},
						to_stdin = true,
						ignore_stderr = true,
					}),
				},
			},
		},
		opts_extend = { "sources" },
	},

	-- LSP Setup
	{
		"neovim/nvim-lspconfig",
		ft = "nix",
		opts = function(_, opts)
			opts.servers.nixd = {
				cmd = { "nixd", "--inlay-hints", "--semantic-tokens" },
				root_markers = { "flake.nix", ".git" },
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
		end,
	},
}
