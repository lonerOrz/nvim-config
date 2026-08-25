return {
	-- Color Highlighter
	"catgoose/nvim-colorizer.lua",
	event = "BufReadPost",
	opts = {
		user_default_options = {
			names = false, -- don't paint identifiers like None / Red
			RGB = true,
			RRGGBB = true,
			RRGGBBAA = true,
			rgb_fn = true,
			hsl_fn = true,
			css = true,
			tailwind = true,
		},
	},
}
