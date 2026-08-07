local toggle_file = vim.fn.stdpath("state") .. "/autoformat.toggle"

local function get_autoformat_state()
	local ok, data = pcall(vim.fn.readfile, toggle_file)
	return ok and data and data[1] == "1"
end

local function set_autoformat_state(enabled)
	vim.fn.writefile({ enabled and "1" or "0" }, toggle_file)
end

return {
	-- Formatter Bridge
	{
		"stevearc/conform.nvim",
		event = { "BufReadPre", "BufNewFile" },
		keys = {
			{
				"<leader>cf",
				function()
					require("conform").format({ async = true, lsp_fallback = true })
				end,
				desc = "Format buffer",
			},
		},
		opts = {
			-- Default formatters for config, markup, and shell scripts
			formatters_by_ft = {
				toml = { "taplo" },
				xml = { "xmlformatter" },
				json = { "prettier" },
				jsonc = { "prettier" },
				yaml = { "prettier" },
				html = { "prettier" },
				css = { "prettier" },
				scss = { "prettier" },
				markdown = { "prettier" },
				sql = { "sql-formatter" },
			},
			format_on_save = function(_)
				if vim.g.enable_autoformat then
					return { timeout_ms = 500, lsp_fallback = true }
				end
			end,
		},
		init = function()
			-- Initialize state and bind Snacks toggle (<leader>tf)
			vim.g.enable_autoformat = get_autoformat_state()

			require("snacks").toggle
				.new({
					id = "auto_format",
					name = "Auto Format",
					get = function()
						return vim.g.enable_autoformat
					end,
					set = function(state)
						vim.g.enable_autoformat = state
						set_autoformat_state(state)
					end,
				})
				:map("<leader>tf")
		end,
	},
}
