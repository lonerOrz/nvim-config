return {
	{
		"zbirenbaum/copilot.lua",
		enabled = true,
		cmd = "Copilot",
		-- event = "VimEnter",
		event = "InsertEnter",
		opts = {
			suggestion = { enabled = false },
			panel = { enabled = false },
			filetypes = {
				markdown = true,
				help = true,
			},
		},
	},
}
