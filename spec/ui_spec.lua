local git_mob = require("git-mob")

describe("ui", function()
	local buf, win
	local original_get_coauthors
	local original_toggle_coauthor

	before_each(function()
		buf = nil
		win = nil
		original_get_coauthors = git_mob.api.get_coauthors
		original_toggle_coauthor = git_mob.api.toggle_coauthor
	end)

	after_each(function()
		git_mob.api.get_coauthors = original_get_coauthors
		git_mob.api.toggle_coauthor = original_toggle_coauthor
		if win and vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
		if buf and vim.api.nvim_buf_is_valid(buf) then vim.api.nvim_buf_delete(buf, { force = true }) end
	end)

	it("shows co-authors in a buffer", function()
		git_mob.api.get_coauthors = function()
			return {
				{ initials = "aa", name = "Alice Anders", email = "alice@example.org", active = true },
				{ initials = "bb", name = "Bob Barnes", email = "bob@example.org", active = false },
			}
		end

		local result = git_mob.ui.select_coauthors()
		buf, win = result.buf, result.win

		local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
		assert(#lines == 2, ("Expected 2 lines, got %d"):format(#lines))
		assert(lines[1]:find("Alice Anders"), ("Expected Alice Anders in line 1: %s"):format(lines[1]))
		assert(lines[2]:find("Bob Barnes"), ("Expected Bob Barnes in line 2: %s"):format(lines[2]))
	end)

	it("marks active co-authors with [*] and inactive with [ ]", function()
		git_mob.api.get_coauthors = function()
			return {
				{ initials = "aa", name = "Alice Anders", email = "alice@example.org", active = true },
				{ initials = "bb", name = "Bob Barnes", email = "bob@example.org", active = false },
			}
		end

		local result = git_mob.ui.select_coauthors()
		buf, win = result.buf, result.win

		local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
		assert(lines[1]:sub(1, 3) == "[*]", ("Expected active marker in line 1: %s"):format(lines[1]))
		assert(lines[2]:sub(1, 3) == "[ ]", ("Expected inactive marker in line 2: %s"):format(lines[2]))
	end)
end)
