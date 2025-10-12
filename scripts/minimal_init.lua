-- scripts/minimal_init.lua
-- Headless testing with mini.test, no user config loaded.

local DEPENDECIES_DIR = "./.dependencies"
local MINITEST_DIR = DEPENDECIES_DIR .. "/mini.nvim"

-- Speed up startup
for _, p in ipairs({
	"gzip",
	"zip",
	"zipPlugin",
	"tar",
	"tarPlugin",
	"vimball",
	"vimballPlugin",
	"2html_plugin",
	"matchit",
	"matchparen",
	"netrw",
	"netrwPlugin",
	"netrwSettings",
	"netrwFileHandlers",
	"rrhelper",
	"spellfile_plugin",
	"shada_plugin",
}) do
	vim.g["loaded_" .. p] = 1
end

vim.opt.shortmess:append("I")
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false

-- Put repo + deps on RTP
vim.opt.runtimepath:append(".")
vim.opt.runtimepath:append(MINITEST_DIR) -- or ./deps/mini.test if you vendor it standalone

-- Auto-clone mini.nvim if missing (vendor to deps/)
if vim.fn.isdirectory(MINITEST_DIR) == 0 then
	vim.fn.mkdir(MINITEST_DIR, "p")
	vim.fn.system({
		"git",
		"clone",
		"--depth",
		"1",
		"https://github.com/nvim-mini/mini.nvim",
		MINITEST_DIR,
	})
end

-- Enable mini.test
require("mini.test").setup({
	collect = {
		emulate_busted = true, -- lets you keep describe/it style
		-- Use your existing spec layout:
		find_files = function()
			return vim.fn.globpath("spec", "**/*_spec.lua", true, true)
		end,
	},
	execute = {
		-- stdio reporter for CI/headless runs:
		reporter = require("mini.test").gen_reporter.stdout(),
		stop_on_error = false,
	},
	-- Optional: put custom project runner here and call it instead of MiniTest.run()
	-- script_path = "scripts/minitest.lua",
})
