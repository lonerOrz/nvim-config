local is_nixos = vim.fn.executable("nixos-rebuild") == 1 or vim.fn.isdirectory("/nix/store") == 1

-- Use system wrapped clangd on NixOS
local clangd_bin = "clangd"
if is_nixos and vim.fn.executable("/run/current-system/sw/bin/clangd") == 1 then
	clangd_bin = "/run/current-system/sw/bin/clangd"
end

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
		opts = {
			ensure_installed = not is_nixos and { "clangd", "clang-format" } or { "clang-format" },
		},
		opts_extend = { "ensure_installed" },
	},
	-- LSP
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				clangd = {
					cmd = {
						clangd_bin,
						"--background-index",
						"--clang-tidy",
						"--header-insertion=iwyu",
						"--completion-style=detailed",
						"--function-arg-placeholders",
						"--fallback-style=llvm",
					},
					root_markers = { "compile_commands.json", "compile_flags.txt", ".git" },
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
				c = { "clang-format" },
				cpp = { "clang-format" },
			},
		},
	},
}
