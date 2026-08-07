return {
	-- AI Completion Engine
	{
		"Exafunction/windsurf.nvim",
		lazy = false,
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		opts = {
			enable_cmp_source = false,
			virtual_text = {
				enabled = true,
				manual = true,
			},
		},
		config = function(_, opts)
			require("codeium").setup(opts)
		end,
	},

	-- Extend blink cmp with Codeium source
	{
		"saghen/blink.cmp",
		optional = true,
		dependencies = { "Exafunction/windsurf.nvim" },
		opts = function(_, opts)
			opts.sources = opts.sources or {}
			opts.sources.providers = opts.sources.providers or {}

			opts.sources.providers.codeium = {
				name = "Codeium",
				module = "codeium.blink",
				async = true,
			}

			opts.sources.default = opts.sources.default or {}
			if type(opts.sources.default) == "table" then
				table.insert(opts.sources.default, 2, "codeium")
			end

			return opts
		end,
	},

	-- Extend Lualine statusbar with Codeium status
	{
		"nvim-lualine/lualine.nvim",
		optional = true,
		opts = function(_, opts)
			opts.sections = opts.sections or {}
			opts.sections.lualine_c = opts.sections.lualine_c or {}

			-- Dynamic status string
			local function get_codeium_status()
				local state = "idle"
				pcall(function()
					state = require("codeium.virtual_text").status().state
				end)

				if state == "waiting" then
					return " Waiting..."
				end
				return " Codeium"
			end

			-- Dynamic status color
			local function get_codeium_color()
				local theme = require("catppuccin.palettes").get_palette("mocha")
				local state = "idle"
				pcall(function()
					state = require("codeium.virtual_text").status().state
				end)

				if state == "waiting" then
					return { fg = theme.peach }
				elseif state == "completions" then
					return { fg = theme.green }
				end
				return { fg = theme.mauve }
			end

			table.insert(opts.sections.lualine_c, {
				get_codeium_status,
				color = get_codeium_color,
			})

			return opts
		end,
	},
}
