-- Window Navigation
vim.keymap.set("n", "<C-Left>", "<C-w>h", { desc = "Go to left window" })
vim.keymap.set("n", "<C-Right>", "<C-w>l", { desc = "Go to right window" })
vim.keymap.set("n", "<C-Down>", "<C-w>j", { desc = "Go to lower window" })
vim.keymap.set("n", "<C-Up>", "<C-w>k", { desc = "Go to upper window" })

-- Line Head & Tail
vim.keymap.set({ "n", "x" }, "<S-H>", "^", { desc = "Start of line" })
vim.keymap.set({ "n", "x" }, "<S-L>", "$", { desc = "End of line" })
vim.keymap.set("n", "y<S-H>", "y^", { desc = "Yank from start of line" })
vim.keymap.set("n", "y<S-L>", "y$", { desc = "Yank to end of line" })

-- Quick Save & Quit
vim.keymap.set({ "n", "x" }, "Q", "<CMD>:qa<CR>", { desc = "Quit all" })
vim.keymap.set({ "n", "x" }, "qq", "<CMD>:q<CR>", { desc = "Quit current window" })
vim.keymap.set("n", "<C-s>", "<CMD>w<CR>", { desc = "Save file" })

-- Line Wrap Toggle
vim.keymap.set("n", "<A-z>", "<CMD>set wrap!<CR>", { desc = "Toggle line wrap" })

-- Visual Indentation
vim.keymap.set("x", ">", ">gv", { noremap = true, silent = true })
vim.keymap.set("x", "<", "<gv", { noremap = true, silent = true })

-- Utilities
vim.keymap.set("v", "<leader>tt", [[: !xargs -I {} ts "{}"<CR>]], { desc = "Translate selection" })
vim.keymap.set("n", "<leader>u", function()
	pcall(vim.cmd, "packadd nvim.undotree")
	require("undotree").open()
end, { desc = "Open undotree" })

-- Universal Floating Preview Window Scroller
local function scroll_floating_preview(lines)
	local current_win = vim.api.nvim_get_current_win()
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		local config = vim.api.nvim_win_get_config(win)
		if win ~= current_win and config.relative ~= "" then
			vim.api.nvim_win_call(win, function()
				local key = lines > 0 and "\x05" or "\x19"
				vim.cmd("normal! " .. math.abs(lines) .. key)
			end)
			return true
		end
	end
	return false
end

-- Global Preview Scrolling Keys (Alt + Up/Down for ALL plugins)
vim.keymap.set({ "n", "i", "t" }, "<A-Down>", function()
	scroll_floating_preview(5)
end, { desc = "Scroll floating preview down" })

vim.keymap.set({ "n", "i", "t" }, "<A-Up>", function()
	scroll_floating_preview(-5)
end, { desc = "Scroll floating preview up" })
