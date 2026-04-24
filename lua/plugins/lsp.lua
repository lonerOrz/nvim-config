return {
	{
		"williamboman/mason.nvim",
		cmd = { "Mason", "MasonInstall", "MasonUpdate" },
		opts = {
			ensure_installed = {
				"lua-language-server",
				"rust-analyzer",
			},
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
	{
		"williamboman/mason-lspconfig.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} },
			"neovim/nvim-lspconfig",
		},
		opts = {
			automatic_enable = {
				exclude = { "nil_ls" },
			},
		},
	},
	{
		"glepnir/lspsaga.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lspsaga").setup({
				-- Lightbulb 配置，控制 code action 提示
				lightbulb = {
					enable = true, -- 启用 lightbulb
					sign = false, -- 禁止在行号显示 💡
				},
			})

			-- 可选：清理旧的 lightbulb sign，避免遗留
			vim.fn.sign_unplace("LspsagaLightBulb")
		end,
	},

	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = { "saghen/blink.cmp", "williamboman/mason.nvim" },

		opts = {
			--- 🧩 全局 Diagnostic 配置
			diagnostic = {
				underline = true,
				signs = false,
				update_in_insert = false,
				virtual_text = { spacing = 2, prefix = "●" },
				severity_sort = true,
				float = { border = "rounded" },
			},

			--- Mason 统一 setup
			mason_handlers = {},

			--- LSP 服务器配置（可被其他模块扩展，如 nixd）
			servers = {},
		},

		config = function(_, opts)
			-- 🧩 Diagnostic 全局配置
			vim.diagnostic.config(opts.diagnostic)

			-- 增强可见性
			vim.cmd([[
      highlight! DiagnosticUnderlineError guisp=#FF0000 gui=undercurl
      highlight! DiagnosticVirtualTextError guifg=#FF4C4C
      highlight! link DiagnosticHint DiagnosticWarn
    ]])

			-- LSP Capabilities from blink.cmp
			local blink_cmp = require("blink.cmp")
			local capabilities = blink_cmp.get_lsp_capabilities()

			-- 保存 capabilities 到全局变量以供其他模块使用
			_G.lsp_capabilities = capabilities

			local mason_lspconfig = require("mason-lspconfig")
			local mason_mappings = mason_lspconfig.get_mappings()
			mason_lspconfig.setup({
				handlers = {
					function(server_name)
						local server_opts = vim.tbl_deep_extend("force", {
							capabilities = capabilities,
						}, opts.servers[server_name] or {})
						vim.lsp.config(server_name, server_opts)
					end,
				},
			})

			for server_name, server_opts in pairs(opts.servers) do
				if server_opts and not mason_mappings.lspconfig_to_package[server_name] then
					local final_opts = vim.tbl_deep_extend("force", {
						capabilities = capabilities,
					}, server_opts or {})
					vim.lsp.config(server_name, final_opts)
					vim.lsp.enable(server_name)
				end
			end

			-- 🔧 LspAttach 后设置快捷键
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(ev)
					-- 🧠 Hover Doc
					vim.keymap.set("n", "K", "<CMD>Lspsaga hover_doc<CR>", {
						buffer = ev.buf,
						desc = "[LSP] Hover documentation",
					})

					-- 🪄 Signature Help
					vim.keymap.set("n", "gk", vim.lsp.buf.signature_help, {
						buffer = ev.buf,
						desc = "[LSP] Signature help",
					})

					-- 🧭 Go to Definition
					vim.keymap.set("n", "gd", vim.lsp.buf.definition, {
						buffer = ev.buf,
						desc = "[LSP] Go to definition",
					})

					-- 🔍 References
					vim.keymap.set("n", "gr", vim.lsp.buf.references, {
						buffer = ev.buf,
						desc = "[LSP] Find references",
					})

					-- ⏪ Jump Back
					vim.keymap.set("n", "<C-o>", "<C-o>", {
						buffer = ev.buf,
						desc = "[LSP] Jump back",
					})

					-- ✏️ Rename
					vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, {
						buffer = ev.buf,
						desc = "[LSP] Rename symbol",
					})

					-- 💡 Code Action
					vim.keymap.set("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", {
						buffer = ev.buf,
						desc = "[LSP] Code action",
					})

					-- 🗂️ Workspace 管理
					vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, { buffer = ev.buf })
					vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, { buffer = ev.buf })
					vim.keymap.set("n", "<leader>wl", function()
						vim.notify(vim.inspect(vim.lsp.buf.list_workspace_folders()))
					end, { buffer = ev.buf })
				end,
			})
		end,
	},

	{
		"folke/lazydev.nvim",
		ft = "lua", -- only load on lua files
		opts = {
			library = {
				-- See the configuration section for more details
				-- Load luvit types when the `vim.uv` word is found
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},
	{
		-- 代码诊断显示信息
		"folke/trouble.nvim",
		cmd = "Trouble",
		keys = {
			{
				"<A-j>",
				function()
					vim.diagnostic.jump({ count = 1 })
				end,
				mode = { "n" },
				desc = "Go to next diagnostic",
			},
			{
				"<A-k>",
				function()
					vim.diagnostic.jump({ count = -1 })
				end,
				mode = { "n" },
				desc = "Go to previous diagnostic",
			},

			{
				"<leader>cd",
				"<CMD>Trouble diagnostics toggle<CR>",
				desc = "[Trouble] Toggle buffer diagnostics",
			},
			{ "<leader>cs", "<CMD>Trouble symbols toggle focus=false<CR>", desc = "[Trouble] Toggle symbols " },
			-- { "<leader>gl", "<CMD>Trouble lsp toggle focus=false win.position=right<CR>", desc = "[Trouble] Toggle LSP definitions/references/...", },
			-- { "<leader>gL", "<CMD>Trouble loclist toggle<CR>",                            desc = "[Trouble] Location List" },
			-- { "<leader>gq", "<CMD>Trouble qflist toggle<CR>",                             desc = "[Trouble] Quickfix List" },

			-- { "grr", "<CMD>Trouble lsp_references focus=true<CR>",         mode = { "n" }, desc = "[Trouble] LSP references"                        },
			-- { "gD", "<CMD>Trouble lsp_declarations focus=true<CR>",        mode = { "n" }, desc = "[Trouble] LSP declarations"                      },
			-- { "gd", "<CMD>Trouble lsp_type_definitions focus=true<CR>",    mode = { "n" }, desc = "[Trouble] LSP type definitions"                  },
			-- { "gri", "<CMD>Trouble lsp_implementations focus=true<CR>",    mode = { "n" }, desc = "[Trouble] LSP implementations"                   },
		},

		-- specs = {
		--   "folke/snacks.nvim",
		--   opts = function(_, opts)
		--     return vim.tbl_deep_extend("force", opts or {}, {
		--       picker = {
		--         actions = require("trouble.sources.snacks").actions,
		--         win = {
		--           input = {
		--             -- stylua: ignore
		--             keys = {
		--               ["<c-t>"] = { "trouble_open", mode = { "n", "i" }, },
		--             },
		--           },
		--         },
		--       },
		--     })
		--   end,
		-- },
		-- opts = {
		--   focus = false,
		--   warn_no_results = false,
		--   open_no_results = true,
		--   preview = {
		--     type = "float",
		--     relative = "editor",
		--     border = "rounded",
		--     title = "Preview",
		--     title_pos = "center",
		--     ---`row` and `col` values relative to the editor
		--     position = { 0.3, 0.3 },
		--     size = { width = 0.6, height = 0.5 },
		--     zindex = 200,
		--   },
		-- },

		-- lualine 的显示
		config = function(_, opts)
			require("trouble").setup(opts)
		end,
	},
}
