return {
	-- Color Highlighter
	"catgoose/nvim-colorizer.lua",
	event = "BufReadPost",
	config = function()
		require("colorizer").setup()
	end,
}
