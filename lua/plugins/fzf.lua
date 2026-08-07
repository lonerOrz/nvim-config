-- lua/plugins/fzf.lua
return {
	"ibhagwan/fzf-lua",
	event = "VeryLazy",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local fzf = require("fzf-lua")
		fzf.setup({
			winopts = {
				height = 0.85,
				width = 0.80,
				row = 0.5,
				col = 0.5,
				border = "rounded",
			},
		})

		-- 项目根目录查找
		vim.keymap.set("n", "<leader><space>", function()
			fzf.files({ cwd = vim.fn.getcwd() })
		end, { desc = "[FZF] Find files (Project Root)" })

		-- 用户主目录查找
		vim.keymap.set("n", "<leader>fa", function()
			fzf.files({ cwd = "~" })
		end, { desc = "[FZF] Find files (Home Dir)" })
	end,
}
