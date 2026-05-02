return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		opts = {
			transparent_background = true,
			custom_highlights = function(colors)
				return {
					LineNr = { fg = colors.surface2 },
					Visual = { bg = colors.overlay0 },
					Search = { bg = colors.surface2 },
					IncSearch = { bg = colors.mauve },
					CurSearch = { bg = colors.mauve },
					MatchParen = { bg = colors.mauve, fg = colors.base, bold = true },

					NormalFloat = { bg = "NONE" },
					FloatBorder = { bg = "NONE" },
					CursorLine = { bg = "NONE" },
					CursorLineNr = { bg = "NONE" },

					-- 一些常见插件浮动窗口透明
					TelescopeNormal = { bg = "NONE" },
					TelescopeBorder = { bg = "NONE" },
					NoicePopup = { bg = "NONE" },
					NotifyBackground = { bg = "NONE" },
					SnacksPickerListCursorLine = { bg = "NONE" },
				}
			end,
			integrations = {
				barbar = true,
				blink_cmp = true,
				gitsigns = true,
				mason = true,
				noice = true,
				rainbow_delimiters = true,
				snacks = {
					enabled = true,
					indent_scope_color = "flamingo",
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
