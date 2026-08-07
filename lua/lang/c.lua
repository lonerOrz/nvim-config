local is_nixos = vim.fn.executable("nixos-rebuild") == 1 or vim.fn.isdirectory("/nix/store") == 1

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
		ft = { "c", "cpp", "objc", "objcpp" },
		opts = function(_, opts)
			-- Safe capabilities lookup fallback for Normal mode
			local ok, blink_cmp = pcall(require, "blink.cmp")
			local capabilities = ok and blink_cmp.get_lsp_capabilities() or vim.lsp.protocol.make_client_capabilities()

			-- Use system wrapped clangd on NixOS
			local clangd_bin = "clangd"
			if is_nixos and vim.fn.executable("/run/current-system/sw/bin/clangd") == 1 then
				clangd_bin = "/run/current-system/sw/bin/clangd"
			end

			local clangd_opts = {
				cmd = {
					clangd_bin,
					"--background-index",
					"--clang-tidy",
					"--header-insertion=iwyu",
					"--completion-style=detailed",
					"--function-arg-placeholders",
					"--fallback-style=llvm",
				},
				filetypes = { "c", "cpp", "objc", "objcpp" },
				root_markers = { "compile_commands.json", "compile_flags.txt", ".git" },
				capabilities = capabilities,
			}

			opts.servers = opts.servers or {}
			opts.servers.clangd = clangd_opts

			-- Enable clangd using Neovim 0.12 native API
			vim.lsp.config("clangd", clangd_opts)
			vim.lsp.enable("clangd")

			return opts
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
