return {
	-- Statusline Lualine
	{
		"nvim-lualine/lualine.nvim",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		opts_extend = { "sections.lualine_c", "sections.lualine_x" },
		opts = {
			options = {
				theme = "catppuccin-mocha",
				always_divide_middle = false,
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch", "diff", "diagnostics" },
				lualine_c = { "lsp_status" },
				lualine_x = {
					{
						"%S",
						color = "Statement",
						padding = { left = 1, right = 1 },
					},
				},
				lualine_y = { "encoding", "fileformat", "filetype", "progress" },
				lualine_z = { "location" },
			},
		},
		config = function(_, opts)
			local function show_macro_recording()
				local recording_register = vim.fn.reg_recording()
				if recording_register == "" then
					return ""
				else
					return "󰑋 " .. recording_register
				end
			end

			local macro_recording = {
				show_macro_recording,
				color = function()
					local c = require("theme.theme").palette()
					return { fg = c.base, bg = c.red }
				end,
				separator = { left = "", right = "" },
				padding = 0,
			}

			table.insert(opts.sections.lualine_x, 1, macro_recording)
			require("lualine").setup(opts)
		end,
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
			-- modern / classic / helix
			preset = "helix",

			-- Show immediately
			delay = 0,

			-- Vim builtin / operator / text-object help
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
				-- Leader Root Groups
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

				-- Leader Top-level Direct Shortcuts
				{ "<leader><space>", icon = "󰥩", desc = "Find files (Project)" },
				{ "<leader>q", icon = "󰗼", desc = "Quit all" },
				{ "<leader>L", icon = "󰒲", desc = "Open Lazy UI" },
				{ "<leader>?", icon = "󰋖", desc = "Show keymaps" },

				-- Builtin Namespaces & Operators
				{ "g", group = "Goto / LSP Actions", icon = "󱔗" },
				{ "gz", group = "Surround", icon = "󰑤", mode = { "n", "x" } },
				{ "z", group = "Fold / View", icon = "󰁮" },
				{ "]", group = "Next (Hunk / Diag / Ref)", icon = "󰒮" },
				{ "[", group = "Prev (Hunk / Diag / Ref)", icon = "󰒭" },
			},

			-- Popup scrolling
			keys = {
				scroll_down = "<C-j>",
				scroll_up = "<C-k>",
			},

			-- Window appearance
			win = {
				width = 0.5,
				padding = { 1, 2 },
				title = true,
				title_pos = "center",
				border = "rounded",
			},

			-- Column layout
			layout = {
				width = {
					min = 20,
				},
				spacing = 3,
			},

			-- Expand groups that have no description
			expand = function(node)
				return not node.desc
			end,
		},

		keys = {
			{
				"<leader>?",
				function()
					require("which-key").show()
				end,
				desc = "Show keymaps",
			},
		},
	},
}
