-- Folding: indent-based folding, uniform across all filetypes.
-- `foldmethod=indent` makes each indentation level a fold, so `za`/`zc`
-- collapse exactly the block under the cursor — no per-language logic.

-- Closed-fold text: "  +-- N lines ", indented to match the block.
local function foldtext()
	local indent = vim.fn.indent(vim.v.foldstart - 1)
	local size = 1 + vim.v.foldend - vim.v.foldstart
	return string.rep(" ", indent) .. "  +-- " .. size .. " lines "
end

-- foldmethod is window-local; set it for every window (incl. later buffers).
vim.api.nvim_create_autocmd("BufWinEnter", {
	group = vim.api.nvim_create_augroup("UserFoldMethod", { clear = true }),
	callback = function()
		vim.wo.foldmethod = "indent"
	end,
})

-- Appearance / behavior
vim.o.foldenable = true
vim.o.foldcolumn = "1"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldignore = ""
vim.opt.fillchars:append("fold: ")
vim.opt.foldopen:remove({ "hor", "block" })
vim.o.foldtext = "v:lua.require('config.fold').foldtext()"

-- Make } / { jump past folds instead of opening them.
vim.keymap.set("n", "}", "foldclosed(search('^$', 'Wn')) == -1 ? '}' : '}j}'", { expr = true })
vim.keymap.set("n", "{", "foldclosed(search('^$', 'Wnb')) == -1 ? '{' : '{k{'", { expr = true })

return { foldtext = foldtext }
