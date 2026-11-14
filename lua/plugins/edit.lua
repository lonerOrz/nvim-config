return {
	-- Auto Pairs
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		opts = {
			disable_filetype = { "TelescopePrompt", "spectre_panel", "racket", "scheme" },
		},
	},

	-- Parinfer: pure Lua implementation
	{
		"gpanders/nvim-parinfer",
		ft = { "racket", "scheme" },
	},

	{
		"echasnovski/mini.surround",
		keys = function(_, keys)
			local plugin = require("lazy.core.config").spec.plugins["mini.surround"]
			local opts = require("lazy.core.plugin").values(plugin, "opts", false)

			local mappings = {
				{ opts.mappings.add, desc = "Add Surrounding", mode = { "n", "x" } },
				{ opts.mappings.delete, desc = "Delete Surrounding" },
				{ opts.mappings.replace, desc = "Replace Surrounding" },
			}
			mappings = vim.tbl_filter(function(m)
				return m[1] and #m[1] > 0
			end, mappings)
			return vim.list_extend(mappings, keys)
		end,
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
					---@diagnostic disable-next-line: undefined-field
					require("snacks").picker.todo_comments()
				end,
				desc = "Pick todos (All, incl. NOTE)",
			},
		},
		opts = {},
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
