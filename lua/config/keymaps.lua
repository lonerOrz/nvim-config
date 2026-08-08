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
vim.keymap.set("n", "<C-s>", "<CMD>w<CR>", { desc = "Save file" })
vim.keymap.set("n", "Q", "<CMD>confirm q<CR>", { desc = "Quit current window" })
vim.keymap.set("n", "<leader>q", "<CMD>confirm qa<CR>", { desc = "Quit all" })

-- Line Wrap Toggle
vim.keymap.set("n", "<A-z>", "<CMD>set wrap!<CR>", { desc = "Toggle line wrap" })

-- Visual Indentation
vim.keymap.set("x", ">", ">gv", { noremap = true, silent = true })
vim.keymap.set("x", "<", "<gv", { noremap = true, silent = true })

-- Utilities
vim.keymap.set("v", "<leader>tt", [[: !xargs -I {} ts "{}"<CR>]], { desc = "Translate selection" })

-- Neovim Native Undotree
vim.keymap.set("n", "<leader>u", function()
	pcall(function()
		vim.cmd("packadd nvim.undotree")
	end)
	require("undotree").open()
end, { desc = "Open native undotree" })

-- Floating Preview Scroller
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

-- Scroll Floating Preview (<A-j> / <A-k>)
vim.keymap.set({ "n", "i", "t" }, "<A-j>", function()
	if not scroll_floating_preview(5) then
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<A-j>", true, false, true), "n", false)
	end
end, { desc = "Scroll floating preview down" })

vim.keymap.set({ "n", "i", "t" }, "<A-k>", function()
	if not scroll_floating_preview(-5) then
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<A-k>", true, false, true), "n", false)
	end
end, { desc = "Scroll floating preview up" })

-- Close Floating Windows
vim.keymap.set("n", "<Esc>", function()
	local current_win = vim.api.nvim_get_current_win()
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		local config = vim.api.nvim_win_get_config(win)
		if win ~= current_win and config.relative ~= "" then
			pcall(function()
				vim.api.nvim_win_close(win, true)
			end)
		end
	end
end, { desc = "Close floating window" })

-- Duplicate Line Preserving Cursor
vim.keymap.set({ "n", "i" }, "<A-d>", function()
	local is_insert = (vim.api.nvim_get_mode().mode == "i")
	local col = vim.fn.col(".")

	vim.cmd("copy .")
	vim.fn.cursor(vim.fn.line("."), col)

	if is_insert then
		vim.cmd("startinsert" .. (col >= vim.fn.col("$") and "!" or ""))
	end
end, { desc = "Duplicate line preserving cursor" })
