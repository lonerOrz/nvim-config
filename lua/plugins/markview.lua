return {
	-- Markdown Previewer
	"OXY2DEV/markview.nvim",
	ft = "markdown",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons",
	},
	keys = {
		{
			"<leader>ms",
			"<CMD>Markview splitToggle<CR>",
			ft = "markdown",
			desc = "Toggle Markdown split preview",
		},
		{
			"<leader>mm",
			"<CMD>Markview toggle<CR>",
			ft = "markdown",
			desc = "Toggle inline Markdown render",
		},
		{
			"<leader>mh",
			"<CMD>Markview hybridToggle<CR>",
			ft = "markdown",
			desc = "Toggle hybrid mode (raw cursor line)",
		},
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
