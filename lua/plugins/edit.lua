return {
	-- Auto Pairs
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		opts = {
			ignored_next_char = "[%w%.]",
		},
	},

	{
		"echasnovski/mini.surround",
		event = "VeryLazy",
		opts = {
			mappings = {
				add = "gza", -- Add surrounding
				delete = "gzd", -- Delete surrounding
				replace = "gzr", -- Replace surrounding
			},
		},
	},

	-- Motion Navigation (Flash)
	{
		"folke/flash.nvim",
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
			-- Bare key passthrough for speed
			{
				"s",
				mode = { "n", "x", "o" },
				function()
					require("flash").jump()
				end,
				desc = "Flash jump",
			},
			-- Standard entries (<leader>j Jump group)
			{
				"<leader>jj",
				mode = { "n", "x", "o" },
				function()
					require("flash").jump()
				end,
				desc = "Flash jump",
			},
			{
				"<leader>jt",
				mode = { "n", "x", "o" },
				function()
					require("flash").treesitter()
				end,
				desc = "Flash treesitter",
			},
			{
				"<leader>jT",
				mode = { "o", "x" },
				function()
					require("flash").treesitter_search()
				end,
				desc = "Flash treesitter search",
			},
			{
				"<leader>jl",
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
			{
				"<c-f>",
				mode = { "c" },
				function()
					require("flash").toggle()
				end,
				desc = "Toggle flash search",
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
				"<leader>sT",
				function()
					require("snacks").picker.todo_comments()
				end,
				desc = "Pick todos (All, incl. NOTE)",
			},
		},
		config = true,
	},

	-- UNIX Shell Commands Helper
	{
		"tpope/vim-eunuch",
		cmd = {
			"Delete",
			"Unlink",
			"Remove",
			"Move",
			"Rename",
			"Chmod",
			"Mkdir",
			"SudoEdit",
			"SudoWrite",
		},
	},
}
