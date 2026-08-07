return {
	-- Markdown Previewer
	"OXY2DEV/markview.nvim",
	lazy = false,
	ft = "markdown",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		require("markview").setup({
			experimental = {
				check_rtp_message = false,
			},
		})
	end,
}
