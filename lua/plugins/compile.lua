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
			-- Smart default command getter
			local function get_default_command()
				local has_just = #vim.fs.find(
					{ "justfile", "Justfile" },
					{ upward = true, path = vim.fn.expand("%:p:h") }
				) > 0
				if has_just then
					return "just build"
				end

				local cmds = {
					c = "gcc % -o %:r && ./%:r",
					cpp = "g++ % -o %:r && ./%:r",
					rust = "cargo check",
					nix = "nix build",
					lua = "lua %",
					python = "python3 %",
					sh = "bash %",
				}
				return cmds[vim.bo.filetype] or "make -k"
			end

			---@type CompileModeOpts
			vim.g.compile_mode = {
				bang_expansion = true,
				baleia_setup = true,
				auto_scroll = true,
				ask_about_save = true,
				default_command = get_default_command,
			}
		end,
	},
}
