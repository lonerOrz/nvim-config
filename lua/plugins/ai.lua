return {
	-- Codeium engine
	{
		"Exafunction/windsurf.nvim",
		event = "VeryLazy",
		cmd = { "Codeium", "CodeiumAuth", "CodeiumToggle", "CodeiumChat" },
		keys = {
			{ "<leader>ac", "<CMD>Codeium Toggle<CR>", mode = { "n" }, desc = "Toggle Codeium completion" },
			{ "<leader>ab", "<CMD>Codeium Chat<CR>", mode = { "n" }, desc = "Open Codeium chat" },
			{ "<leader>aA", "<CMD>Codeium Auth<CR>", mode = { "n" }, desc = "Authenticate Codeium" },
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		opts = {
			enable_cmp_source = false,
			virtual_text = {
				enabled = false,
			},
		},
		config = function(_, opts)
			require("codeium").setup(opts)
		end,
	},

	-- Blink cmp integration
	{
		"saghen/blink.cmp",
		optional = true,
		dependencies = { "Exafunction/windsurf.nvim" },
		opts = function(_, opts)
			opts.keymap = opts.keymap or {}
			-- Trigger Codeium AI completions explicitly
			opts.keymap["<A-y>"] = {
				function(cmp)
					cmp.show({ providers = { "codeium" } })
				end,
			}

			opts.sources = opts.sources or {}
			opts.sources.providers = opts.sources.providers or {}

			opts.sources.providers.codeium = {
				name = "Codeium",
				module = "codeium.blink",
				async = true,
				score_offset = 80,
				enabled = function()
					return vim.api.nvim_buf_get_name(0) ~= "" and vim.bo.buftype == ""
				end,
			}

			opts.sources.default = opts.sources.default or {}
			if type(opts.sources.default) == "table" then
				table.insert(opts.sources.default, 2, "codeium")
			end

			return opts
		end,
	},

	-- Lualine statusline component
	{
		"nvim-lualine/lualine.nvim",
		optional = true,
		opts = function(_, opts)
			opts.sections = opts.sections or {}
			opts.sections.lualine_c = opts.sections.lualine_c or {}

			local function get_codeium_state()
				local vt = package.loaded["codeium.virtual_text"]
				if not vt then
					return "idle"
				end
				return vt.status().state
			end

			table.insert(opts.sections.lualine_c, {
				function()
					local state = get_codeium_state()
					if state == "waiting" then
						return " Waiting..."
					end
					return " Codeium"
				end,
				color = function()
					local theme = require("theme.theme").palette()
					local state = get_codeium_state()

					if state == "waiting" then
						return { fg = theme.peach }
					elseif state == "completions" then
						return { fg = theme.green }
					end
					return { fg = theme.mauve }
				end,
			})

			return opts
		end,
	},
}
