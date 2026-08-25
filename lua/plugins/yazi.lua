return {
	-- Yazi Terminal File Manager
	{
		"mikavilpas/yazi.nvim",
		dependencies = { "folke/snacks.nvim" },
		keys = {
			{ "<leader>ya", "<CMD>Yazi<CR>", desc = "Open at current file", mode = { "n", "v" } },
			{ "<leader>yw", "<CMD>Yazi cwd<CR>", desc = "Open in working directory" },
			{ "<leader>yr", "<CMD>Yazi toggle<CR>", desc = "Resume last session" },
		},
		opts = {
			open_for_directories = false,
			keymaps = {
				show_help = "<f1>",
			},
			hooks = {
				before_opening_window = function(opts)
					local has_statusline = vim.o.laststatus > 0 and 1 or 0
					local bottom = vim.o.lines - vim.o.cmdheight - has_statusline

					opts.relative = "editor"
					opts.col = 0
					opts.width = vim.o.columns
					opts.height = math.floor(bottom * 0.42)
					opts.row = bottom - opts.height
					opts.border = { "", "─", "", "", "", "", "", "" }

					opts.title = " 󰇥 Yazi "
					opts.title_pos = "left"
				end,
			},
		},
		init = function()
			vim.g.loaded_netrwPlugin = 1
		end,
	},
}
