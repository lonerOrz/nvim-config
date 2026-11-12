-- hostname for nixd expr
local _h = vim.uv.os_gethostname()
local _nixos_expr_host = _h:match("^[%a_][%w_]*$") and _h or ('"%s"'):format(_h)

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
		opts = {
			servers = {
				nixd = {
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
									expr = "(builtins.getFlake (toString ./.)).nixosConfigurations["
										.. _nixos_expr_host
										.. "].options",
								},
							},
						},
					},
				},
			},
		},
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
