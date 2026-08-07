return {
	"ibhagwan/fzf-lua",
	event = "VeryLazy",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	keys = {
		-- Refactoring & Code Editing Helpers (<leader>c)
		{
			"<leader>cA",
			function()
				require("fzf-lua").lsp_code_actions()
			end,
			desc = "Code actions (with live diff preview)",
		},
		{
			"<leader>cT",
			function()
				require("fzf-lua").treesitter()
			end,
			desc = "Treesitter AST symbol outline",
		},
		{
			"<leader>cF",
			function()
				require("fzf-lua").lsp_finder()
			end,
			desc = "LSP finder (defs, refs, impls with preview)",
		},

		-- Search Resume (<leader>s)
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
