return {
	-- Blink Completion Engine
	{
		"saghen/blink.cmp",
		event = "InsertEnter",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
			"onsails/lspkind.nvim",
			"folke/lazydev.nvim",
		},
		version = "1.*",

		---@module 'blink.cmp'
		---@type blink.cmp.Config
		opts = {
			keymap = {
				preset = "none",
				["<A-j>"] = {
					function(cmp)
						return cmp.select_next({ auto_insert = false })
					end,
					"fallback",
				},
				["<A-k>"] = {
					function(cmp)
						return cmp.select_prev({ auto_insert = false })
					end,
					"fallback",
				},
				["<C-n>"] = {
					function(cmp)
						return cmp.select_next({ auto_insert = false })
					end,
					"fallback",
				},
				["<C-p>"] = {
					function(cmp)
						return cmp.select_prev({ auto_insert = false })
					end,
					"fallback",
				},

				["<C-u>"] = { "scroll_documentation_up", "fallback" },
				["<C-d>"] = { "scroll_documentation_down", "fallback" },

				["<Tab>"] = {
					function(cmp)
						return cmp.accept()
					end,
					"fallback",
				},
				["<CR>"] = {
					function(cmp)
						return cmp.accept()
					end,
					"fallback",
				},
				["<S-CR>"] = {
					function(cmp)
						cmp.hide()
						return false
					end,
					"fallback",
				},

				["<A-/>"] = {
					function(cmp)
						if cmp.is_menu_visible() then
							return cmp.hide()
						else
							return cmp.show()
						end
					end,
					"fallback",
				},

				["<A-n>"] = {
					function(cmp)
						cmp.show({ providers = { "buffer" } })
					end,
				},
				["<A-p>"] = {
					function(cmp)
						cmp.show({ providers = { "buffer" } })
					end,
				},
			},

			appearance = {
				nerd_font_variant = "normal",
			},

			sources = {
				default = { "lazydev", "lsp", "path", "snippets", "buffer" },
				per_filetype = {},

				providers = {
					lazydev = {
						name = "LazyDev",
						module = "lazydev.integrations.blink",
						score_offset = 95,
					},
					path = {
						score_offset = 95,
						opts = {
							get_cwd = function(_)
								return vim.fn.getcwd()
							end,
						},
					},
					buffer = {
						score_offset = 20,
					},
					lsp = {
						transform_items = function(_, items)
							return vim.tbl_filter(function(item)
								return item.kind ~= require("blink.cmp.types").CompletionItemKind.Text
							end, items)
						end,
						score_offset = 60,
						fallbacks = { "buffer" },
					},
					snippets = {
						score_offset = 70,
						should_show_items = function(ctx)
							return ctx.trigger.initial_kind ~= "trigger_character"
						end,
						fallbacks = { "buffer" },
					},
					cmdline = {
						min_keyword_length = 2,
						enabled = function()
							return vim.fn.getcmdtype() ~= ":" or not vim.fn.getcmdline():match("^[%%0-9,'<>%-]*!")
						end,
					},
				},
			},

			fuzzy = {
				implementation = "prefer_rust_with_warning",
				sorts = {
					"exact",
					"score",
					"sort_text",
				},
			},

			completion = {
				accept = { auto_brackets = { enabled = true } },
				list = { selection = { preselect = true, auto_insert = false } },
				menu = {
					border = "rounded",
					max_height = 20,
					draw = {
						columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } },
						components = {
							kind_icon = {
								ellipsis = false,
								text = function(ctx)
									local icon = ctx.kind_icon
									if icon then
									elseif vim.tbl_contains({ "Path" }, ctx.source_name) then
										local dev_icon, _ = require("nvim-web-devicons").get_icon(ctx.label)
										if dev_icon then
											icon = dev_icon
										end
									else
										icon = require("lspkind").symbolic(ctx.kind)
									end
									return icon .. ctx.icon_gap
								end,
								highlight = function(ctx)
									local hl = ctx.kind_hl
									if hl then
									elseif vim.tbl_contains({ "Path" }, ctx.source_name) then
										local dev_icon, dev_hl = require("nvim-web-devicons").get_icon(ctx.label)
										if dev_icon then
											hl = dev_hl
										end
									end
									return hl
								end,
							},
						},
					},
				},
				documentation = {
					auto_show = true,
					auto_show_delay_ms = 200,
					window = {
						min_width = 10,
						max_width = 120,
						max_height = 20,
						border = "rounded",
						winblend = 0,
						winhighlight = "Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,EndOfBuffer:BlinkCmpDoc",
						scrollbar = true,
						direction_priority = {
							menu_north = { "e", "w", "n", "s" },
							menu_south = { "e", "w", "s", "n" },
						},
					},
				},
				ghost_text = {
					enabled = true,
					show_with_selection = true,
					show_without_selection = false,
					show_with_menu = true,
					show_without_menu = true,
				},
			},

			signature = {
				enabled = true,
				window = {
					min_width = 1,
					max_width = 100,
					max_height = 10,
					border = "single",
					winblend = 0,
					winhighlight = "Normal:BlinkCmpSignatureHelp,FloatBorder:BlinkCmpSignatureHelpBorder",
					scrollbar = false,
					direction_priority = { "n" },
					treesitter_highlighting = true,
					show_documentation = true,
				},
			},

			cmdline = {
				completion = {
					menu = {
						auto_show = true,
					},
				},
				keymap = {
					preset = "none",
					["<A-j>"] = {
						function(cmp)
							return cmp.select_next({ auto_insert = false })
						end,
						"fallback",
					},
					["<A-k>"] = {
						function(cmp)
							return cmp.select_prev({ auto_insert = false })
						end,
						"fallback",
					},
					["<C-p>"] = {
						function(cmp)
							return cmp.select_prev({ auto_insert = false })
						end,
						"fallback",
					},
					["<C-n>"] = {
						function(cmp)
							return cmp.select_next({ auto_insert = false })
						end,
						"fallback",
					},
					["<Tab>"] = {
						function(cmp)
							return cmp.accept()
						end,
						"fallback",
					},
					["<CR>"] = {
						function(cmp)
							if vim.fn.getcmdtype() == ":" then
								return cmp.accept_and_enter()
							end
							return false
						end,
						"fallback",
					},
					["<A-/>"] = {
						function(cmp)
							if cmp.is_menu_visible() then
								return cmp.hide()
							else
								return cmp.show()
							end
						end,
						"fallback",
					},
				},
			},
		},

		opts_extend = { "sources.default" },
	},
}
