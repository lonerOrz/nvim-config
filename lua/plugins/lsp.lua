return {
	-- Mason Dependency Manager
	{
		"mason-org/mason.nvim",
		cmd = { "Mason", "MasonInstall", "MasonUpdate" },
		opts = {
			ensure_installed = {},
		},
		config = function(_, opts)
			require("mason").setup(opts)
			local mr = require("mason-registry")
			local function ensure_installed()
				for _, tool in ipairs(opts.ensure_installed) do
					local p = mr.get_package(tool)
					if not p:is_installed() then
						p:install()
					end
				end
			end
			if mr.refresh then
				mr.refresh(ensure_installed)
			else
				ensure_installed()
			end
		end,
	},

	-- Mason LSPConfig Integration
	{
		"mason-org/mason-lspconfig.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} },
			"neovim/nvim-lspconfig",
		},
		opts = {
			automatic_enable = { exclude = { "nil_ls" } },
		},
	},

	-- Lspsaga (Hover & Code Actions)
	{
		"glepnir/lspsaga.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lspsaga").setup({
				lightbulb = { enable = true, sign = false },
			})
		end,
	},

	-- LSP Core Configuration
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = { "saghen/blink.cmp", "mason-org/mason.nvim" },
		opts = {
			diagnostic = {
				underline = true,
				signs = false,
				update_in_insert = false,
				virtual_text = { spacing = 2, prefix = "●" },
				severity_sort = true,
				float = { border = "rounded" },
			},
			mason_handlers = {},
			servers = {},
		},
		config = function(_, opts)
			vim.diagnostic.config(opts.diagnostic)

			pcall(vim.keymap.del, "n", "grn")
			pcall(vim.keymap.del, "n", "gra")
			pcall(vim.keymap.del, "n", "grr")
			pcall(vim.keymap.del, "n", "gri")

			vim.cmd([[
      highlight! DiagnosticUnderlineError guisp=#FF0000 gui=undercurl
      highlight! DiagnosticVirtualTextError guifg=#FF4C4C
      highlight! link DiagnosticHint DiagnosticWarn
    ]])

			local blink_cmp = require("blink.cmp")
			local capabilities = blink_cmp.get_lsp_capabilities()

			local mason_lspconfig = require("mason-lspconfig")
			local mason_mappings = mason_lspconfig.get_mappings()
			mason_lspconfig.setup({
				handlers = {
					function(server_name)
						local server_opts = vim.tbl_deep_extend(
							"force",
							{ capabilities = capabilities },
							opts.servers[server_name] or {}
						)
						vim.lsp.config(server_name, server_opts)
						vim.lsp.enable(server_name)
					end,
				},
			})

			for server_name, server_opts in pairs(opts.servers) do
				if server_opts and not mason_mappings.lspconfig_to_package[server_name] then
					local final_opts = vim.tbl_deep_extend("force", { capabilities = capabilities }, server_opts or {})
					vim.lsp.config(server_name, final_opts)
					vim.lsp.enable(server_name)
				end
			end

			-- LSP Keymaps Setup
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(ev)
					-- Hover & Help (g)
					vim.keymap.set(
						"n",
						"K",
						"<CMD>Lspsaga hover_doc<CR>",
						{ buffer = ev.buf, desc = "Hover documentation" }
					)
					vim.keymap.set("n", "gk", vim.lsp.buf.signature_help, { buffer = ev.buf, desc = "Signature help" })

					-- Go-to Navigation (g)
					vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = ev.buf, desc = "Go to definition" })
					vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = ev.buf, desc = "Find references" })

					-- Code Actions & Refactoring (<leader>c)
					vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, { buffer = ev.buf, desc = "Rename symbol" })
					vim.keymap.set(
						"n",
						"<leader>ca",
						"<cmd>Lspsaga code_action<CR>",
						{ buffer = ev.buf, desc = "Code action" }
					)

					-- Workspace Management (<leader>w)
					vim.keymap.set(
						"n",
						"<leader>wa",
						vim.lsp.buf.add_workspace_folder,
						{ buffer = ev.buf, desc = "Add workspace folder" }
					)
					vim.keymap.set(
						"n",
						"<leader>wr",
						vim.lsp.buf.remove_workspace_folder,
						{ buffer = ev.buf, desc = "Remove workspace folder" }
					)
					vim.keymap.set("n", "<leader>wl", function()
						vim.notify(vim.inspect(vim.lsp.buf.list_workspace_folders()))
					end, { buffer = ev.buf, desc = "List workspace folders" })
				end,
			})
		end,
	},

	-- LazyDev (Lua API Support)
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = { { path = "${3rd}/luv/library", words = { "vim%.uv" } } },
		},
	},

	-- Trouble Diagnostics Panel
	{
		"folke/trouble.nvim",
		cmd = "Trouble",
		keys = {
			-- Diagnostic Jumping
			{
				"]d",
				function()
					vim.diagnostic.jump({ count = 1 })
				end,
				mode = { "n" },
				desc = "Next diagnostic",
			},
			{
				"[d",
				function()
					vim.diagnostic.jump({ count = -1 })
				end,
				mode = { "n" },
				desc = "Prev diagnostic",
			},

			-- Trouble Toggles (<leader>c)
			{ "<leader>cd", "<CMD>Trouble diagnostics toggle<CR>", desc = "Buffer diagnostics" },
			{ "<leader>cs", "<CMD>Trouble symbols toggle focus=false<CR>", desc = "Document symbols" },
		},
		config = function(_, opts)
			require("trouble").setup(opts)
		end,
	},
}
