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
		},
		init = function()
			vim.g.loaded_netrwPlugin = 1
		end,
	},
}
