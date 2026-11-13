return {
	-- Minuet AI completion engine
	{
		"milanglacier/minuet-ai.nvim",
		event = "InsertEnter",
		priority = 100,
		opts = {
			provider = "openai_compatible",
			throttle = 500,
			debounce = 250,
			request_timeout = 3,
			context_window = 8000,
			context_ratio = 0.75,
			notify = "warn",
			provider_options = {
				openai_compatible = {
					name = "Groq",
					end_point = "https://api.groq.com/openai/v1/chat/completions",
					model = "qwen/qwen3.8-27b",
					api_key = "GROQ_API_KEY",
					optional = {
						max_tokens = 128,
						temperature = 0.1,
					},
				},
			},
			presets = {
				groq = {
					provider = "openai_compatible",
					throttle = 500,
					debounce = 250,
					request_timeout = 3,
					provider_options = {
						openai_compatible = {
							name = "Groq",
							end_point = "https://api.groq.com/openai/v1/chat/completions",
							model = "qwen/qwen3.8-27b",
							api_key = "GROQ_API_KEY",
							optional = {
								max_tokens = 128,
								temperature = 0.1,
							},
						},
					},
				},
				agnes = {
					provider = "openai_compatible",
					throttle = 1000,
					debounce = 300,
					request_timeout = 3,
					provider_options = {
						openai_compatible = {
							name = "Agnes",
							end_point = "https://apihub.agnes-ai.com/v1/chat/completions",
							model = "agnes-2.5-flash",
							api_key = "AGNES_API_KEY",
							optional = {
								max_tokens = 128,
								reasoning_effort = "none",
								temperature = 0.1,
							},
						},
					},
				},
			},
		},
		keys = {
			{
				"<leader>ac",
				"<CMD>Minuet blink toggle<CR>",
				desc = "Toggle Minuet completion",
			},
			{
				"<leader>ap",
				function()
					local minuet = require("minuet")
					local presets = minuet.presets or {}
					local names = vim.tbl_filter(function(name)
						return name ~= "original"
					end, vim.tbl_keys(presets))

					if vim.tbl_isempty(names) then
						vim.notify("No Minuet presets defined", vim.log.levels.WARN)
						return
					end

					table.sort(names)

					-- Determine current preset by matching provider name
					local current_preset = nil
					local provider = minuet.config and minuet.config.provider
					local current_name = provider
						and minuet.config.provider_options[provider]
						and minuet.config.provider_options[provider].name

					if current_name then
						for _, name in ipairs(names) do
							local preset = presets[name]
							local preset_name = preset
								and preset.provider_options
								and preset.provider_options[provider]
								and preset.provider_options[provider].name
							if preset_name == current_name then
								current_preset = name
								break
							end
						end
					end

					-- Move current preset to the front of the list
					if current_preset then
						for i, name in ipairs(names) do
							if name == current_preset then
								table.remove(names, i)
								table.insert(names, 1, current_preset)
								break
							end
						end
					end

					vim.ui.select(names, {
						prompt = "Minuet preset (current: " .. (current_preset or "?") .. "):",
						format_item = function(item)
							return item == current_preset and ("* " .. item) or item
						end,
					}, function(choice)
						if choice then
							minuet.change_preset(choice)
						end
					end)
				end,
				desc = "Switch Minuet preset",
			},
			{
				"<leader>am",
				function()
					require("minuet").change_model()
				end,
				desc = "Change Minuet model",
			},
		},
	},

	-- Blink.cmp integration
	{
		"saghen/blink.cmp",
		optional = true,
		opts = function(_, opts)
			opts.keymap = opts.keymap or {}
			opts.keymap["<A-y>"] = {
				function(cmp)
					cmp.show({ providers = { "minuet" } })
				end,
			}

			opts.sources = opts.sources or {}
			opts.sources.providers = opts.sources.providers or {}
			opts.sources.providers.minuet = {
				name = "Minuet",
				module = "minuet.blink",
				async = true,
				timeout_ms = 3000,
				score_offset = 80,
				enabled = function()
					return vim.bo.buftype == ""
						and vim.api.nvim_buf_get_name(0) ~= ""
						and not vim.tbl_contains({ "help", "qf", "terminal", "oil" }, vim.bo.filetype)
				end,
			}

			opts.sources.default = opts.sources.default or {}
			if type(opts.sources.default) == "table" then
				table.insert(opts.sources.default, 2, "minuet")
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

			table.insert(opts.sections.lualine_c, {
				function()
					local icon = " "
					local minuet = package.loaded["minuet"]
					if not minuet or not minuet.config then
						return icon .. " AI"
					end

					local provider = minuet.config.provider
					local po = minuet.config.provider_options[provider]
					if not po then
						return icon .. " AI"
					end

					-- Display only icon + provider name
					return icon .. " " .. (po.name or provider)
				end,
				color = function()
					local ok, palette = pcall(require, "theme.theme")
					if ok and palette.palette then
						return { fg = palette.palette().mauve }
					end
					return { fg = "#cba6f7" }
				end,
				padding = { left = 1, right = 1 },
			})

			return opts
		end,
	},
}
