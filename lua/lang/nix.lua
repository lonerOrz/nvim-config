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

	-- LSP Server Configuration ( need nixd)
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
