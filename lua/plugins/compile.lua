-- Walk upward from the current file's directory; return first match.
local function find_upward(name)
	local dir = vim.fn.expand("%:p:h")
	if dir == "" then
		dir = vim.fn.getcwd()
	end
	return vim.fs.find(name, { upward = true, path = dir, limit = 1 })[1]
end

-- Single-file commands (fallback).
local single = {
	c = "gcc % -Wall -Wextra -std=c17 -o %:p:r && %:p:r",
	cpp = "g++ % -Wall -Wextra -std=c++20 -o %:p:r && %:p:r",
	rust = "rustc % -o %:p:r && %:p:r",
	go = "go run %",
	zig = "zig run %",
	java = "javac % && java %:t:r",
	kotlin = "kotlin %",
	scala = "scala %",
	python = "python3 %",
	lua = "lua %",
	sh = "bash %",
	zsh = "zsh %",
	fish = "fish %",
	ruby = "ruby %",
	php = "php %",
	perl = "perl %",
	racket = "racket %",
	clojure = "clojure %",
	javascript = "node %",
	typescript = "tsx %",
	deno = "deno run -A %",
	julia = "julia %",
	r = "Rscript %",
	haskell = "runghc %",
	ocaml = "ocaml %",
	elixir = "elixir %",
	erlang = "escript %",
	swift = "swift %",
	dart = "dart run %",
	nim = "nim r %",
	crystal = "crystal run %",
	v = "v run %",
	odin = "odin run %",
	fsharp = "dotnet fsi %",
	groovy = "groovy %",
}

-- Project-level commands: used when any marker is found upward.
local project = {
	rust = { marker = "Cargo.toml", cmd = "cargo run" },
	go = { marker = "go.mod", cmd = "go run ." },
	zig = { marker = "build.zig", cmd = "zig build run" },
	nix = { marker = "flake.nix", cmd = "nix run" },
	elixir = { marker = "mix.exs", cmd = "mix run" },
	ocaml = { marker = "dune-project", cmd = "dune exec" },
	haskell = { marker = { "stack.yaml", "cabal.project" }, cmd = "stack run" },
	swift = { marker = "Package.swift", cmd = "swift run" },
	dart = { marker = "pubspec.yaml", cmd = "dart run" },
	julia = { marker = "Project.toml", cmd = "julia --project=. %" },
	java = { marker = { "pom.xml", "build.gradle", "build.gradle.kts" }, cmd = "gradle run" },
	javascript = { marker = "package.json", cmd = "npm start" },
	typescript = { marker = "tsconfig.json", cmd = "tsc --noEmit" },
	deno = { marker = "deno.json", cmd = "deno task start" },
}

local function get_default_command()
	local ft = vim.bo.filetype

	-- justfile has highest priority.
	if find_upward({ "justfile", "Justfile" }) then
		return "just build"
	end

	local p = project[ft]
	if p then
		local markers = type(p.marker) == "table" and p.marker or { p.marker }
		for _, m in ipairs(markers) do
			if find_upward(m) then
				return p.cmd
			end
		end
	end

	-- scheme: prefer guile when available.
	if ft == "scheme" then
		return vim.fn.executable("guile") == 1 and "guile %" or "racket %"
	end

	return single[ft] or ""
end

return {
	{
		"ej-shafran/compile-mode.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"m00qek/baleia.nvim",
		},
		cmd = { "Compile", "Recompile" },
		keys = {
			{ "<leader>cm", "<CMD>15Compile<CR>", desc = "Compile default command" },
			{ "<leader>cr", "<CMD>15Recompile<CR>", desc = "Recompile last command" },
		},

		init = function()
			-- Close the compilation buffer with `q`.
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "compilation",
				callback = function(ev)
					vim.bo[ev.buf].buflisted = false
					vim.keymap.set("n", "q", "<CMD>bdelete!<CR>", {
						buffer = ev.buf,
						silent = true,
						nowait = true,
					})
				end,
			})

			vim.g.compile_mode = {
				bang_expansion = true,
				ansi_color = {
					kind = "render",
				},
				auto_scroll = true,
				ask_about_save = true,
				focus_compilation_buffer = true,
				auto_jump_to_first_error = false,
				-- Literal 1 == WARNING (avoid require at startup).
				error_threshold = 1,
				default_command = get_default_command,
			}
		end,
	},
}
