return {
	"cordx56/rustowl",
	-- Install rustowl manually. If you prefer `cargo binstall rustowl`,
	-- install cargo-binstall first with `cargo install cargo-binstall`.
	enabled = vim.fn.executable("rustowl") == 1,
	version = "*", -- Latest stable version
	lazy = false, -- This plugin is already lazy
	opts = {
		client = {
			on_attach = function(_, buffer)
				vim.keymap.set("n", "<leader>o", function()
					require("rustowl").toggle(buffer)
				end, { buffer = buffer, desc = "Toggle RustOwl" })
			end,
		},
	},
}
