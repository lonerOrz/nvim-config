return {
	-- Multifunctional Suite
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
			zen = {
				enabled = true,
				toggles = {
					dim = true,
					git_signs = false,
					mini_diff_signs = false,
				},
				center = true,
				show = {
					statusline = false,
					tabline = false,
				},
				win = { style = "zen" },
				on_open = function(win)
					-- 清掉 lspsaga 写到 zen 浮窗的 winbar
					vim.api.nvim_create_autocmd("CursorMoved", {
						group = win.augroup,
						buffer = win.buf,
						callback = function()
							if vim.api.nvim_win_is_valid(win.win) then
								vim.wo[win.win].winbar = ""
							end
						end,
					})
				end,
				zoom = {
					toggles = {},
					center = false,
					show = { statusline = false, tabline = false },
					win = {
						backdrop = false,
						width = 0,
					},
				},
			},
			words = { enabled = true },
			styles = {
				zen = {
					enter = true,
					fixbuf = false,
					minimal = false,
					width = 120,
					height = 0,
					backdrop = { transparent = true, blend = 40 },
					keys = { q = false },
					zindex = 40,
					wo = {
						winhighlight = "NormalFloat:Normal",
					},
					w = {
						snacks_main = true,
					},
				},
				zoom_indicator = {
					text = "▍ zoom  󰊓  ",
					minimal = true,
					enter = false,
					focusable = false,
					height = 1,
					row = 0,
					col = -1,
					backdrop = false,
				},
				terminal = {
					relative = "editor",
					border = "rounded",
					position = "float",
					backdrop = 60,
					height = 0.8,
					width = 0.8,
					zindex = 50,
				},
			},
			dashboard = {
				enabled = true,

				sections = {
					function()
						return {
							align = "center",
							padding = 1,
							text = {
								{ "│ ", hl = "Special" },
								{ "╲ ││\n", hl = "String" },
								{ "││", hl = "Special" },
								{ "╲╲││\n", hl = "String" },
								{ "││ ", hl = "Special" },
								{ "╲ │", hl = "String" },
							},
						}
					end,

					function()
						local v = vim.version()

						return {
							align = "center",
							text = {
								{
									string.format("NVIM v%d.%d.%d", v.major, v.minor, v.patch),
									hl = "String",
								},
							},
						}
					end,

					{
						align = "center",
						padding = 1,
					},

					{
						align = "center",
						text = {
							{ "Nvim is open source and freely distributable" },
						},
					},

					{
						align = "center",
						text = {
							{
								"https://neovim.io/#chat",
								hl = "SnacksDashboardDesc",
							},
						},
					},

					{
						align = "center",
						text = { "" },
					},

					-- Lazy.nvim
					{
						align = "center",
						action = ":Lazy",
						key = "l",
						text = {
							{ "type  " },
							{ "l", hl = "SnacksDashboardKey" },
							{ string.format("  %-20s", "to open Lazy") },
						},
					},

					-- New File
					{
						align = "center",
						action = ":ene | startinsert",
						key = "n",
						text = {
							{ "type  " },
							{ "n", hl = "SnacksDashboardKey" },
							{ string.format("  %-20s", "to create new file") },
						},
					},

					-- Mason
					{
						align = "center",
						action = ":Mason",
						key = "m",
						text = {
							{ "type  " },
							{ "m", hl = "SnacksDashboardKey" },
							{ string.format("  %-20s", "to open Mason") },
						},
					},

					-- Config
					{
						align = "center",
						action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
						key = "c",
						text = {
							{ "type  " },
							{ "c", hl = "SnacksDashboardKey" },
							{ string.format("  %-20s", "to browse config") },
						},
					},

					-- Quit
					{
						align = "center",
						action = ":qa",
						key = "q",
						text = {
							{ "type  " },
							{ "q", hl = "SnacksDashboardKey" },
							{ string.format("  %-20s", "to exit") },
						},
					},

					{
						align = "center",
						text = { "" },
					},

					-- startup
					function()
						local stats = require("lazy.stats").stats()
						local ms = math.floor(stats.startuptime * 100 + 0.5) / 100

						return {
							align = "center",
							padding = 1,
							text = {
								{ "󰔟  ", hl = "SnacksDashboardIcon" },
								{ stats.loaded .. "/" .. stats.count, hl = "SnacksDashboardKey" },
								{ " plugins · ", hl = "SnacksDashboardDesc" },
								{ ms .. " ms", hl = "SnacksDashboardKey" },
							},
						}
					end,
				},
			},
		},
		keys = {
			-- Terminal & Buffer Tools
			{
				"<C-`>",
				function()
					require("snacks").terminal()
				end,
				desc = "Toggle floating terminal",
				mode = { "n", "t" },
			},
			{
				"<leader>bs",
				function()
					require("snacks").scratch()
				end,
				desc = "Toggle Scratchpad",
			},
			{
				"<leader>bb",
				function()
					require("snacks").picker.buffers()
				end,
				desc = "List buffers",
			},
			{
				"<leader>bd",
				function()
					require("snacks").bufdelete()
				end,
				desc = "Delete buffer",
			},
			{
				"<leader>bD",
				function()
					require("snacks").bufdelete(nil, true)
				end,
				desc = "Delete other buffers",
			},
			{ "<A-Left>", "<CMD>bprevious<CR>", desc = "Previous buffer" },
			{ "<A-Right>", "<CMD>bnext<CR>", desc = "Next buffer" },

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
			-- Zen Mode (<leader>z)
			{
				"<leader>zt",
				function()
					require("snacks").zen()
				end,
				desc = "Toggle Zen Mode",
			},
			{
				"<leader>zz",
				function()
					require("snacks").zen.zoom()
				end,
				desc = "Toggle Zoom (Maximize)",
			},

			-- Code & Refactor Tools (<leader>c)
			{
				"<leader>cR",
				function()
					require("snacks").rename.rename_file()
				end,
				desc = "Rename current file",
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
					Snacks.toggle.option("conceallevel", { off = 0, on = 2 }):map("<leader>tc")
					Snacks.toggle.treesitter():map("<leader>tT")
					Snacks.toggle
						.new({
							id = "git_blame",
							name = "Git Line Blame",
							get = function()
								return require("gitsigns.config").config.current_line_blame
							end,
							set = function(state)
								require("gitsigns").toggle_current_line_blame(state)
							end,
						})
						:map("<leader>tB")
					Snacks.toggle
						.option("background", { off = "light", on = "dark", name = "Dark Background" })
						:map("<leader>tb")
					Snacks.toggle.inlay_hints():map("<leader>th")
					Snacks.toggle.indent():map("<leader>tg")
					Snacks.toggle.profiler():map("<leader>tpp")
					Snacks.toggle.profiler_highlights():map("<leader>tph")
				end,
			})
		end,
	},
}
