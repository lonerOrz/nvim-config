-- Add mason bin path to PATH
vim.env.PATH = vim.env.PATH .. ":" .. vim.fn.stdpath("data") .. "/mason/bin:/bin"

-- Errors do not prevent startup
require("vim._core.ui2").enable({
	enable = true,
})

require("config.options")
require("config.lazy")
require("config.keymaps")
