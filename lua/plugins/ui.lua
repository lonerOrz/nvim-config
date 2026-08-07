return {
	-- Web Devicons
	{
		"nvim-tree/nvim-web-devicons",
		opts = {
			override = {
				copilot = {
					icon = "",
					color = "#cba6f7",
					name = "Copilot",
				},
			},
		},
	},

	-- Statusline (Lualine)
	{
		"nvim-lualine/lualine.nvim",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
			"AndreM222/copilot-lualine",
			"folke/trouble.nvim",
		},
		opts = {
			options = {
				theme = "catppuccin-mocha",
				always_divide_middle = false,
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch", "diff", "diagnostics" },
				lualine_c = { "lsp_status" },
				lualine_x = {},
				lualine_y = { "encoding", "fileformat", "filetype", "progress" },
				lualine_z = { "location" },
			},
		},
		config = function(_, opts)
			local theme = require("catppuccin.palettes").get_palette("mocha")

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
				color = { fg = "#333333", bg = theme.red },
				separator = { left = "", right = "" },
				padding = 0,
			}

			local copilot = {
				"copilot",
				show_colors = true,
				symbols = {
					status = {
						hl = {
							enabled = theme.green,
							sleep = theme.overlay0,
							disabled = theme.surface0,
							warning = theme.peach,
							unknown = theme.red,
						},
					},
					spinner_color = theme.mauve,
				},
			}

			table.insert(opts.sections.lualine_x, 1, macro_recording)
			table.insert(opts.sections.lualine_c, copilot)
			require("lualine").setup(opts)
		end,
	},

	-- Buffer Tabline (Barbar)
	{
		"romgrk/barbar.nvim",
		version = "^1.0.0",
		dependencies = {
			"lewis6991/gitsigns.nvim",
			"nvim-tree/nvim-web-devicons",
		},
		init = function()
			vim.g.barbar_auto_setup = false
		end,
		event = { "VeryLazy" },
		keys = {
			-- Buffer Navigation (Alt + Arrow Keys)
			{ "<A-Left>", "<CMD>BufferPrevious<CR>", mode = { "n" }, desc = "Previous buffer" },
			{ "<A-Right>", "<CMD>BufferNext<CR>", mode = { "n" }, desc = "Next buffer" },
			{ "<A-w>", "<CMD>BufferClose<CR>", mode = { "n" }, desc = "Close buffer" },
			{ "<A-<>", "<CMD>BufferMovePrevious<CR>", mode = { "n" }, desc = "Move buffer left" },
			{ "<A->>", "<CMD>BufferMoveNext<CR>", mode = { "n" }, desc = "Move buffer right" },

			-- Direct Buffer Navigation
			{ "<A-1>", "<CMD>BufferGoto 1<CR>", mode = { "n" }, desc = "Go to buffer 1" },
			{ "<A-2>", "<CMD>BufferGoto 2<CR>", mode = { "n" }, desc = "Go to buffer 2" },
			{ "<A-3>", "<CMD>BufferGoto 3<CR>", mode = { "n" }, desc = "Go to buffer 3" },
			{ "<A-4>", "<CMD>BufferGoto 4<CR>", mode = { "n" }, desc = "Go to buffer 4" },
			{ "<A-5>", "<CMD>BufferGoto 5<CR>", mode = { "n" }, desc = "Go to buffer 5" },
			{ "<A-6>", "<CMD>BufferGoto 6<CR>", mode = { "n" }, desc = "Go to buffer 6" },
			{ "<A-7>", "<CMD>BufferGoto 7<CR>", mode = { "n" }, desc = "Go to buffer 7" },
			{ "<A-8>", "<CMD>BufferGoto 8<CR>", mode = { "n" }, desc = "Go to buffer 8" },
			{ "<A-9>", "<CMD>BufferGoto 9<CR>", mode = { "n" }, desc = "Go to buffer 9" },
		},
		opts = {
			animation = true,
			auto_hide = 1,
		},
	},

	-- Rainbow Delimiters
	{
		"HiPhish/rainbow-delimiters.nvim",
		main = "rainbow-delimiters.setup",
		submodules = false,
		opts = {},
	},

	-- Command Line UI (Noice)
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = { "MunifTanjim/nui.nvim" },
		opts = {
			popupmenu = { enabled = false },
			lsp = {
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
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
				{ filter = { event = "msg_show", kind = "" }, opts = { skip = true } },
			},
		},
	},

	-- Git Diff Signs
	{
		"echasnovski/mini.diff",
		event = "VeryLazy",
		version = "*",
		opts = {},
	},

	-- Keymap Popup Hints (Which-Key)
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			preset = "helix",
			win = { width = 0.5 },
			spec = {
				{ "<leader>s", group = "Search & Snacks", icon = "󰍉" },
				{ "<leader>c", group = "Code & Format", icon = "󰅩" },
				{ "<leader>t", group = "Toggle Options", icon = "" },
				{ "<leader>p", group = "Sessions", icon = "󰆍" },
				{ "<leader>y", group = "Yazi Manager", icon = "󰇥" },
				{ "<leader>l", group = "Lazygit", icon = "󰊢" },
				{ "<leader>n", group = "Notifications", icon = "󰵅" },
				{ "<leader>w", group = "Workspace", icon = "󰁨" },
				{ "<leader>cc", group = "CodeCompanion", icon = "" },
				{ "g", group = "LSP Navigation", icon = "󰏿" },
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
				desc = "Buffer local keymaps",
			},
		},
	},

	-- Multifunctional Suite (Snacks)
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			bigfile = { enabled = true },
			explorer = { enabled = false },
			image = {
				enabled = true,
				doc = { inline = false, float = true, max_width = 80, max_height = 40 },
				math = { latex = { font_size = "small" } },
			},
			indent = {
				enabled = true,
				animate = { enabled = false },
				indent = { only_scope = true },
				scope = { enabled = true, underline = true },
				chunk = { enabled = true },
			},
			input = { enabled = true },
			notifier = { enabled = true, style = "notification" },
			picker = {
				enabled = true,
				previewers = { git = { builtin = false, args = {} } },
				sources = { spelling = { layout = { preset = "select" } } },
				layout = { preset = "telescope" },
			},
			statuscolumn = { enabled = true },
			terminal = { enabled = true },
			words = { enabled = true },
			styles = {
				terminal = {
					relative = "editor",
					border = "rounded",
					position = "float",
					backdrop = 60,
					height = 0.6,
					width = 0.6,
					zindex = 50,
				},
			},
			dashboard = {
				formats = {
					key = function(item)
						return { { "[", hl = "special" }, { item.key, hl = "key" }, { "]", hl = "special" } }
					end,
				},
				sections = {
					{ section = "header" },
					{ icon = "󰌌 ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
					{ icon = "󰈔 ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
					{ icon = "󰉋 ", title = "Projects", section = "projects", indent = 2, padding = 1 },
					{ section = "startup" },
				},
			},
		},
		keys = {
			-- Terminal & Buffer Tools
			{
				"<A-w>",
				function()
					require("snacks").bufdelete()
				end,
				desc = "Delete buffer",
			},
			{
				"<A-p>",
				function()
					require("snacks").terminal()
				end,
				desc = "Toggle floating terminal",
				mode = { "n", "t" },
			},

			-- Notifications (<leader>n)
			{
				"<leader>ns",
				function()
					require("snacks").picker.notifications()
				end,
				desc = "Notification history",
			},
			{
				"<leader>nu",
				function()
					require("snacks").notifier.hide()
				end,
				desc = "Dismiss notifications",
			},

			-- Search & Pickers (<leader>s)
			{
				"<leader><space>",
				function()
					require("snacks").picker.files()
				end,
				desc = "Find files (Project)",
			},
			{
				"<leader>,",
				function()
					require("snacks").picker.buffers()
				end,
				desc = "List buffers",
			},
			{
				"<leader>sb",
				function()
					require("snacks").picker.buffers()
				end,
				desc = "List buffers",
			},
			{
				"<leader>sf",
				function()
					require("snacks").picker.files()
				end,
				desc = "Find files (Project)",
			},
			{
				"<leader>sd",
				function()
					require("snacks").picker.files({ cwd = vim.fn.expand("%:p:h") })
				end,
				desc = "Find files (Current dir)",
			},
			{
				"<leader>sH",
				function()
					require("snacks").picker.files({ cwd = "~" })
				end,
				desc = "Find files (Home dir)",
			},
			{
				"<leader>sp",
				function()
					require("snacks").picker.projects()
				end,
				desc = "Search projects",
			},
			{
				"<leader>sr",
				function()
					require("snacks").picker.recent()
				end,
				desc = "Recent files",
			},
			{
				"<leader>sg",
				function()
					require("snacks").picker.grep()
				end,
				desc = "Grep text (Project)",
			},
			{
				"<leader>sl",
				function()
					require("snacks").picker.lines()
				end,
				desc = "Search lines in buffer",
			},
			{
				"<leader>s/",
				function()
					require("snacks").picker.lines()
				end,
				desc = "Search lines in buffer",
			},
			{
				"<leader>sw",
				function()
					require("snacks").picker.grep_word()
				end,
				desc = "Grep word under cursor",
				mode = { "n", "x" },
			},
			{
				"<leader>si",
				function()
					require("snacks").image.hover()
				end,
				desc = "Display image",
			},
			{
				'<leader>s"',
				function()
					require("snacks").picker.registers()
				end,
				desc = "View registers",
			},
			{
				"<leader>s:",
				function()
					require("snacks").picker.command_history()
				end,
				desc = "Command history",
			},
			{
				"<leader>sa",
				function()
					require("snacks").picker.spelling()
				end,
				desc = "Spelling suggestions",
			},
			{
				"<leader>sA",
				function()
					require("snacks").picker.autocmds()
				end,
				desc = "Autocommands",
			},
			{
				"<leader>sc",
				function()
					require("snacks").picker.commands()
				end,
				desc = "List commands",
			},
			{
				"<leader>sD",
				function()
					require("snacks").picker.diagnostics()
				end,
				desc = "Workspace diagnostics",
			},
			{
				"<leader>sh",
				function()
					require("snacks").picker.help()
				end,
				desc = "Help pages",
			},
			{
				"<leader>sI",
				function()
					require("snacks").picker.icons()
				end,
				desc = "Icons picker",
			},
			{
				"<leader>sj",
				function()
					require("snacks").picker.jumps()
				end,
				desc = "Jump list",
			},
			{
				"<leader>sk",
				function()
					require("snacks").picker.keymaps()
				end,
				desc = "List keymaps",
			},
			{
				"<leader>sm",
				function()
					require("snacks").picker.marks()
				end,
				desc = "List marks",
			},
			{
				"<leader>sq",
				function()
					require("snacks").picker.qflist()
				end,
				desc = "Quickfix list",
			},
			{
				"<leader>su",
				function()
					require("snacks").picker.undo()
				end,
				desc = "Undo history",
			},
			{
				"<leader>sz",
				function()
					require("snacks").zen()
				end,
				desc = "Toggle Zen Mode",
			},

			-- Git Integration (<leader>l)
			{
				"<leader>lb",
				function()
					require("snacks").git.blame_line()
				end,
				desc = "Git blame line",
			},

			-- LSP Symbols (g)
			{
				"gs",
				function()
					require("snacks").picker.lsp_symbols()
				end,
				desc = "Document symbols",
			},
			{
				"gS",
				function()
					require("snacks").picker.lsp_workspace_symbols()
				end,
				desc = "Workspace symbols",
			},

			-- Reference Jump
			{
				"]]",
				function()
					require("snacks").words.jump(vim.v.count1)
				end,
				desc = "Next reference",
				mode = { "n", "t" },
			},
			{
				"[[",
				function()
					require("snacks").words.jump(-vim.v.count1)
				end,
				desc = "Prev reference",
				mode = { "n", "t" },
			},
		},

		init = function()
			local Snacks = require("snacks")
			vim.api.nvim_create_autocmd("User", {
				pattern = "VeryLazy",
				callback = function()
					_G.dd = function(...)
						Snacks.debug.inspect(...)
					end
					_G.bt = function()
						Snacks.debug.backtrace()
					end
					vim.print = _G.dd

					-- UI Toggles (<leader>t)
					Snacks.toggle
						.new({
							id = "Animation",
							name = "Animation",
							get = function()
								return Snacks.animate.enabled()
							end,
							set = function(state)
								vim.g.snacks_animate = state
							end,
						})
						:map("<leader>ta")
					Snacks.toggle
						.new({
							id = "scroll_anima",
							name = "Scroll animation",
							get = function()
								return Snacks.scroll.enabled
							end,
							set = function(state)
								if state then
									Snacks.scroll.enable()
								else
									Snacks.scroll.disable()
								end
							end,
						})
						:map("<leader>tS")
					Snacks.toggle.dim():map("<leader>tD")
					Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>ts")
					Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>tw")
					Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>tL")
					Snacks.toggle.diagnostics():map("<leader>td")
					Snacks.toggle.line_number():map("<leader>tl")
					Snacks.toggle
						.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
						:map("<leader>tc")
					Snacks.toggle.treesitter():map("<leader>tT")
					Snacks.toggle
						.option("background", { off = "light", on = "dark", name = "Dark Background" })
						:map("<leader>tb")
					Snacks.toggle.inlay_hints():map("<leader>th")
					Snacks.toggle.indent():map("<leader>tg")
					Snacks.toggle.profiler():map("<leader>tpp")
					Snacks.toggle.profiler_highlights():map("<leader>tph")

					vim.keymap.del("n", "grn")
					vim.keymap.del("n", "gra")
					vim.keymap.del("n", "grr")
					vim.keymap.del("n", "gri")

					vim.api.nvim_set_hl(0, "SnacksPickerListCursorLine", { bg = "#313244" })
				end,
			})
		end,
	},
}
