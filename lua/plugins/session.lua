return {
	-- Auto Session Manager
	{
		"rmagatti/auto-session",
		keys = {
			{ "<leader>ps", "<CMD>Autosession search<CR>", desc = "Search session" },
			{ "<leader>pr", "<CMD>SessionRestore<CR>", desc = "Restore session" },
			{ "<leader>pd", "<CMD>Autosession delete<CR>", desc = "Delete session" },
		},
		opts = {
			auto_restore = false,
			suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
		},
		init = function()
			vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
		end,
	},
}
