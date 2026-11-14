return {
	-- Statusline: Lualine
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts_extend = { "sections.lualine_c", "sections.lualine_x" },

		opts = (function()
			-- Catppuccin Mocha palette
			local function get_palette()
				local ok, palettes = pcall(require, "catppuccin.palettes")
				if not ok then
					return nil
				end

				local success, colors = pcall(palettes.get_palette, "mocha")

				return success and colors or nil
			end

			-- Macro recording indicator
			local macro_recording = {
				function()
					local reg = vim.fn.reg_recording()
					return reg == "" and "" or ("󰑋 " .. reg)
				end,

				color = function()
					local C = get_palette()
					return C and {
						fg = C.base,
						bg = C.red,
					} or nil
				end,

				padding = { left = 1, right = 1 },
			}

			-- Session indicator
			local session_status = {
				"%S",

				color = function()
					local C = get_palette()
					return C and {
						fg = C.lavender,
					} or nil
				end,

				padding = { left = 1, right = 1 },
			}

			return {
				options = {
					theme = "catppuccin-mocha",

					-- No separators: spacing creates visual hierarchy
					component_separators = "",
					section_separators = "",

					always_divide_middle = false,
				},

				sections = {
					-- Left: Mode
					lualine_a = {
						{
							"mode",
							padding = { left = 2, right = 2 },
						},
					},

					-- Git & Diagnostics
					lualine_b = {
						"branch",
						"diff",
						"diagnostics",
					},

					-- LSP
					lualine_c = {
						"lsp_status",
					},

					-- Macro & Session
					lualine_x = {
						macro_recording,
						session_status,
					},

					-- File information
					lualine_y = {
						"encoding",
						"fileformat",
						"filetype",
						"progress",
					},

					-- Cursor position
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
		event = { "BufReadPre", "BufNewFile" },
		main = "rainbow-delimiters.setup",
		submodules = false,
		opts = {},
	},

	-- Command Line UI
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = { "MunifTanjim/nui.nvim" },
		opts = {
			-- 通知层交给 snacks.notifier 接管,noice 不再抢 vim.notify
			messages = { enabled = false },
			popupmenu = { enabled = false },
			lsp = {
				-- K is handled by lspsaga; keep noice out of hover
				hover = { enabled = false },
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
				{ filter = { event = "msg_show", kind = "search_count" }, opts = { skip = true } },
			},
		},
	},

	-- Keymap Popup Hints
	{
		"folke/which-key.nvim",
		event = "VeryLazy",

		opts = {
			preset = "helix", -- 布局预设：classic / modern / helix
			delay = 0, -- 立即弹出，不等待

			plugins = {
				-- presets 只为 Vim/Neovim 原生按键提供“描述”，不创建任何实际映射。
				-- 它解决的是“有哪些键”，分组名称和图标仍需在 spec 中显式指定。
				presets = {
					operators = true, -- d / y / c 等操作符
					motions = true, -- w / b / $ / 0 等移动命令
					text_objects = true, -- iw / aw / i" 等文本对象
					windows = true, -- <C-w> 下的窗口管理键
					nav = true, -- H / L / M / [ / ] 等导航
					z = true, -- zc / zo / z= / z<CR> 等折叠与拼写键
					g = true, -- gg / gf / gi 等 g 前缀命令
				},

				marks = true, -- ' 和 ` 的标记列表
				registers = true, -- " 的寄存器列表（INSERT 下 <C-r>）

				spelling = {
					enabled = true, -- 按 z= 时显示拼写建议
					suggestions = 20, -- 最多显示 20 条建议
				},
			},

			-- 为分组命名 + 配图标。
			spec = {
				-- Leader 根分组
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

				-- 内置预设前缀
				{ "g", group = "Goto / LSP Actions", icon = "󱔗" },
				{ "gz", group = "Surround", icon = "󰑤", mode = { "n", "x" } },
				{ "z", group = "Fold / View", icon = "󰁮" },
				{ "<C-w>", group = "Windows", icon = "" }, -- 对应 presets.windows
				{ "]", group = "Next (Hunk / Diag / Ref)", icon = "󰒮" },
				{ "[", group = "Prev (Hunk / Diag / Ref)", icon = "󰒭" },
			},

			keys = {
				scroll_down = "<C-j>", -- 弹窗内向下滚动
				scroll_up = "<C-k>", -- 弹窗内向上滚动
			},

			win = {
				width = 0.5,
				padding = { 1, 2 },
				title = true,
				title_pos = "center",
				border = "rounded",
			},

			layout = {
				width = { min = 20 },
				spacing = 3,
			},

			-- 展开没有描述的分组
			expand = function(node)
				return not node.desc
			end,
		},

		keys = {
			{
				"<leader>?",
				function()
					require("which-key").show({ global = false }) -- 规范签名；global 默认 true
				end,
				desc = "Show keymaps",
			},
		},
	},
}
