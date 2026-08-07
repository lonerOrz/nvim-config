-- Leader Keys
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Search Settings
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- Scroll & Margins
vim.opt.scrolloff = 15
vim.opt.sidescrolloff = 10
vim.opt.startofline = false

-- Conceal Level
vim.opt.conceallevel = 2

-- Indentation
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true

-- Window Splits
vim.opt.splitbelow = true
vim.opt.splitright = true

-- System Clipboard
vim.opt.clipboard = "unnamedplus"

-- Completion Options
vim.opt.completeopt = { "menu", "menuone", "noselect" }

-- Invisible Characters
vim.opt.list = true
vim.opt.listchars = { trail = "-", space = "·" }

-- Line Numbers & Cursor Line
vim.opt.number = true
vim.opt.relativenumber = true
vim.wo.cursorline = true
vim.wo.wrap = false

-- True Colors
vim.opt.termguicolors = true

-- Persistent Undo
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("state") .. "/undo"

-- Disable Netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Cursor Style
vim.opt.guicursor = {
	"n-v-c:block",
	"i-ci-ve:ver10",
	"r-cr:hor20",
	"o:hor50",
	"a:blinkon500-blinkoff500-blinkwait500",
}

-- Folding Configuration
vim.o.foldenable = true
vim.o.foldcolumn = "1"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldtext = ""

-- Native Trim Trailing Whitespace
vim.api.nvim_create_autocmd("BufWritePre", {
	group = vim.api.nvim_create_augroup("NativeTrimWhitespace", { clear = true }),
	pattern = "*",
	callback = function()
		local save_cursor = vim.fn.getpos(".")
		vim.cmd([[%s/\s\+$//e]])
		vim.fn.setpos(".", save_cursor)
	end,
})

-- Clipboard Integration (WSL & SSH)
local is_wsl = vim.fn.has("wsl") == 1
	or vim.env.WSL_DISTRO_NAME ~= nil
	or (vim.uv.os_uname().release or ""):match("Microsoft") ~= nil

local is_ssh = vim.env.SSH_TTY ~= nil

if is_ssh then
	local osc52 = require("vim.ui.clipboard.osc52")
	vim.g.clipboard = {
		name = "OSC52",
		copy = {
			["+"] = osc52.copy("+"),
			["*"] = osc52.copy("*"),
		},
		paste = {
			["+"] = osc52.paste("+"),
			["*"] = osc52.paste("*"),
		},
	}
elseif is_wsl and vim.fn.executable("wl-copy") == 1 then
	vim.g.clipboard = {
		name = "wslg",
		copy = {
			["+"] = { "wl-copy" },
			["*"] = { "wl-copy" },
		},
		paste = {
			["+"] = { "wl-paste", "--no-newline" },
			["*"] = { "wl-paste", "--no-newline" },
		},
		cache_enabled = 0,
	}
end
