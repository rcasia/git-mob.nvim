-- scripts/minimal_init.lua
-- Headless testing with mini.test, no user config loaded.

local DEPENDENCIES_DIR = "./.dependencies"
local MINITEST_DIR = DEPENDENCIES_DIR .. "/mini.nvim"
local ASCIIUI_DIR = DEPENDENCIES_DIR .. "/ascii-ui.nvim"

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

-- ─────────────────────────────────────────────────────────────
-- Ensure dependencies exist
-- ─────────────────────────────────────────────────────────────

local function ensure_repo(path, url)
	if vim.fn.isdirectory(path) == 0 then
		vim.fn.mkdir(path, "p")
		vim.fn.system({ "git", "clone", "--depth", "1", url, path })
	end
end

ensure_repo(MINITEST_DIR, "https://github.com/nvim-mini/mini.nvim")
ensure_repo(ASCIIUI_DIR, "https://github.com/rcasia/ascii-ui.nvim")

-- ─────────────────────────────────────────────────────────────
-- Runtime path setup
-- ─────────────────────────────────────────────────────────────
vim.opt.runtimepath:append(".")
vim.opt.runtimepath:append(MINITEST_DIR)
vim.opt.runtimepath:append(ASCIIUI_DIR)

-- ─────────────────────────────────────────────────────────────
-- Initialize ascii-ui
-- ─────────────────────────────────────────────────────────────
require("ascii-ui").setup({
	-- minimal config suitable for tests
	auto_render = false,
	enable_logs = false,
})

-- ─────────────────────────────────────────────────────────────
-- Enable mini.test
-- ─────────────────────────────────────────────────────────────
require("mini.test").setup({
	collect = {
		emulate_busted = true,
		find_files = function() return vim.fn.globpath("spec", "**/*_spec.lua", true, true) end,
	},
	execute = {
		reporter = require("mini.test").gen_reporter.stdout(),
		stop_on_error = false,
	},
})
