return {
	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		optional = true,
		opts = { ensure_installed = { "lua" } },
		opts_extend = { "ensure_installed" },
	},

	-- Mason
	{
		"mason-org/mason.nvim",
		optional = true,
		opts = {
			ensure_installed = { "lua-language-server", "stylua" },
		},
		opts_extend = { "ensure_installed" },
	},

	-- LSP
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				lua_ls = {
					-- 减少修改注释时频繁触发诊断
					flags = {
						debounce_text_changes = 150,
					},
					settings = {
						Lua = {
							workspace = {
								checkThirdParty = false,
							},
							completion = {
								callSnippet = "Replace",
							},
							diagnostics = {
								globals = { "vim" },
							},
							hint = {
								enable = true,
								setType = false,
								paramType = true,
								paramName = "Disable",
								semicolon = "Disable",
								arrayIndex = "Disable",
							},
							codeLens = {
								enable = true,
							},
							telemetry = {
								enable = false,
							},
						},
					},
					-- 只在没有项目级 .luarc.json 时注入 Neovim 运行时配置
					on_init = function(client)
						if client.workspace_folders then
							local path = client.workspace_folders[1].name
							if
								path ~= vim.fn.stdpath("config")
								and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
							then
								return
							end
						end

						client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua or {}, {
							runtime = {
								version = "LuaJIT",
								path = {
									"lua/?.lua",
									"lua/?/init.lua",
								},
							},
							workspace = {
								checkThirdParty = false,
								library = {
									vim.env.VIMRUNTIME,
								},
							},
						})
					end,
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
				lua = { "stylua" },
			},
		},
	},
}
