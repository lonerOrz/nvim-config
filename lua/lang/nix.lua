-- ~/.config/nvim/lua/plugins/lang/nix.lua
return {
	{
		"nvim-treesitter/nvim-treesitter",
		ft = "nix",
		opts = {
			ensure_installed = { "nix" },
		},
		opts_extend = { "ensure_installed" },
	},
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
	{
		"neovim/nvim-lspconfig",
		ft = "nix",

		opts = function(_, opts)
			opts.servers.nixd = {
				cmd = { "nixd", "--inlay-hints", "--semantic-tokens" },
				root_markers = { "flake.nix", ".git" },
				settings = {
					nixd = {
						nixpkgs = {
							expr = "import (builtins.getFlake(toString ./.)).inputs.nixpkgs { }",
						},
						formatting = { command = { "nixfmt" } },
						options = {
							nixos = {
								expr = '(builtins.getFlake ("git+file://" + toString ./.)).nixosConfigurations.loneros.options',
							},
						},
					},
				},
			}
		end,
	},
}
