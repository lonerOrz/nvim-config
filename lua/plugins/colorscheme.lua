return {
	-- Catppuccin Theme
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		opts = {
			flavour = "mocha",
			transparent_background = true,
			term_colors = true,
			dim_inactive = {
				enabled = true,
				shade = "dark",
				percentage = 0.15,
			},
			styles = {
				comments = { "italic" },
				conditionals = { "italic" },
				loops = {},
				functions = { "bold" },
				keywords = { "italic" },
				strings = {},
				variables = {},
				numbers = {},
				booleans = { "bold" },
				properties = {},
				types = { "bold" },
				operators = {},
			},
			custom_highlights = function(colors)
				return {
					-- UI & Line Numbers
					LineNr = { fg = colors.surface2 },
					CursorLine = { bg = colors.mantle },
					CursorLineNr = { fg = colors.mauve, bold = true },
					Visual = { bg = colors.surface1, style = { "bold" } },
					Search = { bg = colors.surface2, fg = colors.text },
					IncSearch = { bg = colors.pink, fg = colors.base },
					CurSearch = { bg = colors.mauve, fg = colors.base },
					MatchParen = { bg = colors.mauve, fg = colors.base, bold = true },

					-- Floating Windows & Noice UI
					NormalFloat = { bg = colors.mantle },
					FloatBorder = { bg = colors.mantle, fg = colors.mauve },
					FloatTitle = { bg = colors.mauve, fg = colors.base, bold = true },
					NoicePopup = { bg = colors.mantle },
					NoiceCmdlinePopupBorder = { fg = colors.mauve },

					-- Snacks Pickers
					SnacksPickerListCursorLine = { bg = colors.surface0 },

					-- Barbar Tabline
					BufferTabpageFill = { bg = "NONE" },
					BufferTabpages = { bg = "NONE", fg = colors.mauve },
					BufferCurrent = { bg = colors.surface0, fg = colors.mauve, bold = true },
					BufferCurrentSign = { bg = colors.surface0, fg = colors.mauve },
					BufferCurrentMod = { bg = colors.surface0, fg = colors.peach },
					BufferInactive = { bg = "NONE", fg = colors.overlay0 },
					BufferInactiveSign = { bg = "NONE", fg = colors.surface0 },
					BufferInactiveMod = { bg = "NONE", fg = colors.subtext0 },
					BufferVisible = { bg = "NONE", fg = colors.text },
				}
			end,
			integrations = {
				barbar = true,
				blink_cmp = true,
				gitsigns = true,
				mason = true,
				noice = true,
				rainbow_delimiters = true,
				lspsaga = true,
				treesitter = true,
				notify = true,
				mini = { enabled = true },
				snacks = {
					enabled = true,
					indent_scope_color = "mauve",
				},
				which_key = true,
				flash = true,
				lsp_trouble = true,
			},
		},
		config = function(_, opts)
			require("catppuccin").setup(opts)
			vim.cmd.colorscheme("catppuccin")
		end,
	},
}
