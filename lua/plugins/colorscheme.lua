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
					NormalNC = { bg = "NONE" },

					-- UI & Line Numbers
					LineNr = { fg = colors.surface2 },
					CursorLine = { bg = colors.surface0 },
					CursorLineNr = { fg = colors.mauve, bold = true },
					Visual = { bg = colors.surface1, style = { "bold" } },
					Search = { bg = colors.surface2, fg = colors.text },
					IncSearch = { bg = colors.pink, fg = colors.base },
					CurSearch = { bg = colors.mauve, fg = colors.base },
					MatchParen = { bg = colors.mauve, fg = colors.base, bold = true },
					WinSeparator = { fg = colors.surface0, bg = "NONE" },
					VertSplit = { fg = colors.surface0, bg = "NONE" },

					-- Floating Windows & Noice UI
					NormalFloat = { bg = colors.mantle },
					FloatBorder = { bg = "NONE", fg = colors.mauve },
					FloatTitle = { bg = colors.mauve, fg = colors.base, bold = true },
					NoicePopup = { bg = colors.mantle },
					NoiceCmdlinePopupBorder = { fg = colors.mauve },

					-- Lspsaga hover (winhl targets these; not covered by integrations)
					HoverNormal = { bg = colors.mantle },
					HoverBorder = { bg = "NONE", fg = colors.mauve },
					SagaLightBulb = { fg = colors.yellow, bold = true },
					SagaNormal = { bg = colors.mantle },
					SagaDoc = { bg = colors.mantle },
					SagaWinbar = { fg = colors.mauve },
					SagaTitle = { bg = colors.mauve, fg = colors.base, bold = true },

					-- Float bodies/borders/titles not covered by integrations
					FloatFooter = { fg = colors.overlay0 },
					NoiceCmdlinePopup = { bg = "NONE" },
					NoiceCmdlinePopupTitle = { bg = colors.mauve, fg = colors.base, bold = true },
					WhichKeyNormal = { bg = "NONE" },
					WhichKeyBorder = { bg = "NONE", fg = colors.mauve },
					WhichKeyTitle = { bg = colors.mauve, fg = colors.base, bold = true },
					BlinkCmpMenu = { bg = "NONE" },
					BlinkCmpMenuBorder = { bg = "NONE", fg = colors.mauve },
					BlinkCmpDoc = { bg = "NONE" },
					BlinkCmpDocBorder = { bg = "NONE", fg = colors.mauve },
					BlinkCmpDocSeparator = { fg = colors.overlay0 },
					BlinkCmpSignatureHelp = { bg = "NONE" },
					BlinkCmpSignatureHelpBorder = { bg = "NONE", fg = colors.mauve },
					SnacksPicker = { bg = colors.mantle },
					SnacksPickerBorder = { bg = "NONE", fg = colors.mauve },

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
			-- Hand the full UI spec to the local theme system for rendering
			require("theme.theme").init(opts)
		end,
	},
}
