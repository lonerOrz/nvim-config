return {
	-- Statusline
	{
		"nvim-lualine/lualine.nvim",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		opts_extend = {
			"sections.lualine_c",
			"sections.lualine_x",
		},

		opts = (function()
			-- Catppuccin Mocha 调色板：只取一次，闭包捕获，避免每次状态栏刷新重算
			local function get_palette()
				local ok, palettes = pcall(require, "catppuccin.palettes")
				if not ok then
					return nil
				end

				local success, colors = pcall(palettes.get_palette, "mocha")
				return success and colors or nil
			end
			local palette = get_palette()

			local macro_recording = {
				function()
					local reg = vim.fn.reg_recording()
					return reg == "" and "" or ("󰑋 " .. reg)
				end,

				color = function()
					return palette and {
						fg = palette.base,
						bg = palette.red,
					} or nil
				end,

				padding = { left = 1, right = 1 },
			}

			local session_status = {
				"%S",

				color = function()
					return palette and {
						fg = palette.lavender,
					} or nil
				end,

				padding = { left = 1, right = 1 },
			}

			return {
				options = {
					theme = "catppuccin-mocha",
					component_separators = "",
					section_separators = "",
					always_divide_middle = false,
				},

				sections = {
					lualine_a = {
						{
							"mode",
							padding = { left = 2, right = 2 },
						},
					},

					lualine_b = {
						"branch",
						"diff",
						"diagnostics",
					},

					lualine_c = {
						"lsp_status",
					},

					lualine_x = {
						macro_recording,
						session_status,
					},

					lualine_y = {
						"encoding",
						"fileformat",
						"filetype",
						"progress",
					},

					lualine_z = {
						"location",
					},
				},
			}
		end)(),
	},

	-- Rainbow Delimiters
	{
		"HiPhish/rainbow-delimiters.nvim",
		event = {
			"BufReadPre",
			"BufNewFile",
		},
		main = "rainbow-delimiters.setup",
		submodules = false,
		opts = {},
	},

	-- Command Line & Messages
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim",
		},

		opts = {
			messages = {
				enabled = true,
				view = "notify",
				view_error = "notify",
				view_warn = "notify",
				view_history = "messages",
				view_search = "virtualtext",
			},

			notify = {
				enabled = true,
				view = "notify",
			},

			views = {
				notify = {
					backend = "snacks",
				},
			},

			popupmenu = {
				enabled = false,
			},

			lsp = {
				progress = {
					enabled = true,
					view = "mini",
				},

				message = {
					enabled = true,
					view = "notify",
				},

				hover = {
					enabled = false,
				},

				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
				},
			},

			presets = {
				bottom_search = false,
				command_palette = true,
				long_message_to_split = true,
				inc_rename = false,
				lsp_doc_border = true,
			},

			routes = {
				{
					filter = {
						event = "msg_show",
						kind = "search_count",
					},
					opts = {
						skip = true,
					},
				},
			},
		},
	},

	-- Keymap Hints
	{
		"folke/which-key.nvim",
		event = "VeryLazy",

		opts = {
			preset = "helix",
			delay = 0,

			plugins = {
				presets = {
					operators = true,
					motions = true,
					text_objects = true,
					windows = true,
					nav = true,
					z = true,
					g = true,
				},

				marks = true,
				registers = true,

				spelling = {
					enabled = true,
					suggestions = 20,
				},
			},

			spec = {
				-- Leader Groups
				{ "<leader>a", group = "AI & Agent", icon = "󰚩" },
				{ "<leader>b", group = "Buffer Tools", icon = "󰓩" },
				{ "<leader>c", group = "Code & Refactor", icon = "󰅩" },
				{ "<leader>j", group = "Jump & Motion", icon = "󰁁" },
				{ "<leader>g", group = "Git", icon = "󰊢" },
				{ "<leader>m", group = "Markdown", icon = "󰍔" },
				{ "<leader>n", group = "Notifications", icon = "󰵅" },
				{ "<leader>r", group = "Scheme REPL", icon = "" },
				{ "<leader>s", group = "Search & Find", icon = "󰍉" },
				{ "<leader>t", group = "Toggles & UI", icon = "󰨚" },
				{ "<leader>tp", group = "Profiler", icon = "󰧮" },
				{ "<leader>u", group = "Utilities", icon = "󱁤" },
				{ "<leader>y", group = "Yazi Manager", icon = "󰇥" },
				{ "<leader>o", group = "Org Mode", icon = "" },
				{ "<leader>z", group = "Zen", icon = "󰍡" },

				-- Built-in Prefixes
				{ "g", group = "Goto / LSP Actions", icon = "󱔗" },
				{ "gz", group = "Surround", icon = "󰑤", mode = { "n", "x" } },
				{ "z", group = "Fold / View", icon = "󰁮" },
				{ "<C-w>", group = "Windows", icon = "" },
				{ "]", group = "Next (Hunk / Diag / Ref)", icon = "󰒮" },
				{ "[", group = "Prev (Hunk / Diag / Ref)", icon = "󰒭" },
			},

			keys = {
				scroll_down = "<C-j>",
				scroll_up = "<C-k>",
			},

			win = {
				width = 0.5,
				padding = { 1, 2 },
				title = true,
				title_pos = "center",
				border = "rounded",
			},

			layout = {
				width = {
					min = 20,
				},
				spacing = 3,
			},

			expand = function(node)
				return not node.desc
			end,
		},

		keys = {
			{
				"<leader>?",
				function()
					require("which-key").show({ global = false })
				end,
				desc = "Show keymaps",
			},
		},
	},
}
