return {
	-- Markdown Previewer
	"OXY2DEV/markview.nvim",
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
			preview = {
				-- Skip special buffers and float windows (lspsaga races on filetype)
				condition = function(buf)
					if vim.bo[buf].buftype ~= "" then
						return false
					end
					for _, w in ipairs(vim.fn.win_findbuf(buf)) do
						if vim.api.nvim_win_get_config(w).zindex then
							return false
						end
					end
					return true
				end,
			},
		})
	end,
}
