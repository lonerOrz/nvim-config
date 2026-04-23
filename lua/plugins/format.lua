return {
	"nvimtools/none-ls.nvim",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = { "nvim-lua/plenary.nvim" },
	opts = function(_, user_opts)
		local null_ls = require("null-ls")
		local format_augroup = vim.api.nvim_create_augroup("LspFormatting", {})

		local function get_format_clients(bufnr)
			return vim.tbl_filter(function(client)
				return client:supports_method("textDocument/formatting")
			end, vim.lsp.get_clients({ bufnr = bufnr }))
		end

		local function format_buffer(bufnr)
			bufnr = bufnr or vim.api.nvim_get_current_buf()
			local clients = get_format_clients(bufnr)

			if #clients == 0 then
				vim.notify("No formatter available for this buffer", vim.log.levels.WARN)
				return
			end

			local has_none_ls = vim.tbl_contains(
				vim.tbl_map(function(client)
					return client.name
				end, clients),
				"null-ls"
			)

			vim.lsp.buf.format({
				bufnr = bufnr,
				filter = has_none_ls and function(client)
					return client.name == "null-ls"
				end or nil,
			})
		end

		-- 自动格式化 toggle 文件
		local toggle_state_file = vim.fn.stdpath("state") .. "/autoformat.toggle"

		local function load_toggle_state()
			local ok, data = pcall(vim.fn.readfile, toggle_state_file)
			return ok and data and data[1] == "1"
		end

		local function save_toggle_state(state)
			vim.fn.writefile({ state and "1" or "0" }, toggle_state_file)
		end

		vim.g.enable_autoformat = load_toggle_state()

		if not vim.g.format_lsp_attach_initialized then
			local format_keymap_group = vim.api.nvim_create_augroup("FormatKeymaps", { clear = true })
			vim.api.nvim_create_autocmd("LspAttach", {
				group = format_keymap_group,
				callback = function(args)
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if client and client:supports_method("textDocument/formatting") then
						vim.keymap.set("n", "<leader>cf", function()
							format_buffer(args.buf)
						end, { buffer = args.buf, desc = "Format buffer with LSP" })

						vim.api.nvim_clear_autocmds({ group = format_augroup, buffer = args.buf })
						vim.api.nvim_create_autocmd("BufWritePre", {
							group = format_augroup,
							buffer = args.buf,
							callback = function()
								if vim.g.enable_autoformat then
									format_buffer(args.buf)
								end
							end,
						})
					end
				end,
			})
			vim.g.format_lsp_attach_initialized = true
		end

		-- snacks toggle 控制
		require("snacks").toggle
			.new({
				id = "auto_format",
				name = "Auto Format",
				get = function()
					return vim.g.enable_autoformat
				end,
				set = function(state)
					vim.g.enable_autoformat = state
					save_toggle_state(state)
				end,
			})
			:map("<leader>tf")

		-- 默认 sources
		local default_sources = {
			null_ls.builtins.formatting.black,
			null_ls.builtins.formatting.prettier,
			null_ls.builtins.formatting.clang_format,
			null_ls.builtins.formatting.prettier.with({ filetypes = { "markdown" } }),
			null_ls.builtins.diagnostics.markdownlint,
		}

		-- lazy 会自动合并多个 opts.sources，这里我们显式处理合并
		local merged_sources = vim.list_extend(default_sources, user_opts.sources or {})

		return {
			sources = merged_sources,
		}
	end,
}
