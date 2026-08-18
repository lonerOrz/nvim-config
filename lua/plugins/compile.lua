return {
	-- Emacs-style Compilation Mode
	{
		"ej-shafran/compile-mode.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "m00qek/baleia.nvim", version = "*" },
		},
		cmd = { "Compile", "Recompile" },
		keys = {
			{ "<leader>cm", "<CMD>Compile<CR>", desc = "Start compile" },
			{ "<leader>cR", "<CMD>Recompile<CR>", desc = "Recompile last command" },
			{ "<leader>cq", "<CMD>silent! bdelete! *compilation*<CR>", desc = "Delete compilation buffer" },
		},

		init = function()
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "compilation",
				callback = function(ev)
					vim.bo[ev.buf].buflisted = false

					vim.keymap.set("n", "q", "<CMD>bdelete!<CR>", {
						buffer = ev.buf,
						silent = true,
					})
				end,
			})

			-- Find a file by walking upward from the current file.
			local function find_upward(name)
				local result = vim.fs.find(name, {
					upward = true,
					path = vim.fn.expand("%:p:h"),
				})

				return result[1]
			end

			-- Get the default compilation command.
			local function get_default_command()
				local filetype = vim.bo.filetype

				if find_upward({ "justfile", "Justfile" }) then
					return "just build"
				end

				if filetype == "c" then
					return "gcc % -Wall -Wextra -std=c17 -o %:p:r && ./%:t:r"
				end

				if filetype == "cpp" then
					return "g++ % -Wall -Wextra -std=c++20 -o %:p:r && ./%:t:r"
				end

				if filetype == "rust" then
					if find_upward("Cargo.toml") then
						return "cargo run"
					end

					return "rustc % -o %:p:r && ./%:t:r"
				end

				if filetype == "go" then
					if find_upward("go.mod") then
						return "go run ."
					end

					return "go run %"
				end

				if filetype == "zig" then
					if find_upward("build.zig") then
						return "zig build run"
					end

					return "zig run %"
				end

				if filetype == "java" then
					return "javac % && java %:t:r"
				end

				if filetype == "python" then
					return "python3 %"
				end

				if filetype == "lua" then
					return "lua %"
				end

				if filetype == "sh" then
					return "bash %"
				end

				if filetype == "nix" then
					if find_upward("flake.nix") then
						return "nix run"
					end

					return "nix build"
				end

				return ""
			end

			vim.g.compile_mode = {
				bang_expansion = true,
				baleia_setup = true,
				auto_scroll = true,
				ask_about_save = true,
				focus_compilation_buffer = true,
				auto_jump_to_first_error = true,
				error_threshold = require("compile-mode").level.WARNING,
				default_command = get_default_command,
			}
		end,
	},
}
