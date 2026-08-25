return {
	"ibhagwan/fzf-lua",
	event = "VeryLazy",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	keys = {
		-- Code actions (with live diff preview) (<leader>c)
		{
			"<leader>cA",
			function()
				require("fzf-lua").lsp_code_actions()
			end,
			desc = "Code actions (with live diff preview)",
		},

		-- Outline & finder, standardized under <leader>s (Search group)
		{
			"<leader>st",
			function()
				require("fzf-lua").treesitter()
			end,
			desc = "Search treesitter AST symbols",
		},
		{
			"<leader>sF",
			function()
				require("fzf-lua").lsp_finder()
			end,
			desc = "Search LSP finder (defs/refs/impls)",
		},
		{
			"<leader>sR",
			function()
				require("fzf-lua").resume()
			end,
			desc = "Resume last search",
		},
	},
	config = function(_, opts)
		local fzf = require("fzf-lua")
		fzf.setup(opts)
		fzf.register_ui_select()
	end,
	opts = {
		winopts = {
			height = 0.85,
			width = 0.80,
			row = 0.5,
			col = 0.5,
			border = "rounded",
			preview = {
				layout = "flex",
				horizontal = "right:50%",
			},
		},
	},
}
