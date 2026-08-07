return {
	-- Auto Pairs
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		opts = {
			ignored_next_char = "[%w%.]",
		},
	},

	-- Motion Navigation (Flash)
	{
		"folke/flash.nvim",
		event = "BufReadPost",
		opts = {
			label = {
				rainbow = {
					enabled = true,
					shade = 1,
				},
			},
			modes = {
				char = {
					enabled = false,
				},
			},
		},
		keys = {
			{
				"<leader>f",
				mode = { "n", "x", "o" },
				function()
					require("flash").jump()
				end,
				desc = "Flash jump",
			},
			{
				"<leader>F",
				mode = { "n", "x", "o" },
				function()
					require("flash").treesitter()
				end,
				desc = "Flash treesitter",
			},
			{
				"<leader>F",
				mode = { "o", "x" },
				function()
					require("flash").treesitter_search()
				end,
				desc = "Flash treesitter search",
			},
			{
				"<c-f>",
				mode = { "c" },
				function()
					require("flash").toggle()
				end,
				desc = "Toggle flash search",
			},
			{
				"<leader>j",
				mode = { "n", "x", "o" },
				function()
					require("flash").jump({
						search = { mode = "search", max_length = 0 },
						label = { after = { 0, 0 }, matches = false },
						jump = { pos = "end" },
						pattern = "^\\s*\\S\\?",
					})
				end,
				desc = "Flash line jump",
			},
		},
	},

	-- TODO Comments Highlight
	{
		"folke/todo-comments.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"folke/snacks.nvim",
		},
		event = "VeryLazy",
		keys = {
			{
				"<leader>st",
				function()
					require("snacks").picker.todo_comments({
						keywords = { "TODO", "FIX", "FIXME", "BUG", "FIXIT", "HACK", "WARN", "ISSUE" },
					})
				end,
				desc = "Pick todos (exclude NOTE)",
			},
			{
				"<leader>sT",
				function()
					require("snacks").picker.todo_comments()
				end,
				desc = "Pick todos (include NOTE)",
			},
		},
		config = true,
	},

	-- UNIX Shell Commands Helper
	{
		"tpope/vim-eunuch",
		event = "VeryLazy",
		keys = {},
	},
}
