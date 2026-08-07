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

local function get_node_text_safe(node, bufnr)
	local start_row, start_col, end_row, end_col = node:range()
	local lines = vim.api.nvim_buf_get_lines(bufnr, start_row, end_row + 1, false)
	if #lines == 0 then
		return ""
	end
	lines[1] = string.sub(lines[1], start_col + 1)
	lines[#lines] = string.sub(lines[#lines], 1, end_col)
	return table.concat(lines, " "):gsub("%s+", " "):gsub("^%s+", "")
end

function _G.CustomFoldText()
	local ts = vim.treesitter
	local start_line = vim.v.foldstart
	local end_line = vim.v.foldend
	local folded_lines = end_line - start_line + 1
	local bufnr = 0

	local ok, parser = pcall(ts.get_parser, bufnr)
	if not ok or not parser then
		local fallback = vim.fn.getline(start_line):gsub("^%s+", "")
		return string.format(" %s (%d lines)", fallback, folded_lines)
	end

	local tree = parser:parse()[1]
	local root = tree:root()
	local node = root:named_descendant_for_range(start_line - 1, 0, start_line - 1, 0)

	local target_node_types = {
		"function_definition",
		"function_declaration",
		"method_definition",
		"method_declaration",
		"function_item",
		"class_definition",
		"struct_definition",
		"interface_declaration",
		"impl_item",
		"constructor_declaration",
		"let_binding",
	}

	while node do
		local type = node:type()
		if vim.tbl_contains(target_node_types, type) then
			for child in node:iter_children() do
				if child:named() then
					local child_type = child:type()
					if child_type == "identifier" or child_type == "name" then
						local name = get_node_text_safe(child, bufnr)
						return string.format(" %s (%d lines)", name, folded_lines)
					end
				end
			end
		end
		node = node:parent()
	end

	local fallback = vim.fn.getline(start_line):gsub("^%s+", "")
	return string.format(" %s (%d lines)", fallback, folded_lines)
end

vim.opt.foldtext = "v:lua.CustomFoldText()"

-- System Environment PATH
vim.env.PATH = vim.env.PATH .. ":/bin"

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
