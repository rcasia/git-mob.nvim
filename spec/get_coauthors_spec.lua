-- simple equality helper (no luassert needed)
local function eq(actual, expected)
	if not vim.deep_equal(actual, expected) then
		error(("Expected:\n%s\nBut got:\n%s"):format(vim.inspect(expected), vim.inspect(actual)), 2)
	end
end

local git_mob = require("git-mob")

describe("get coauthors feature", function()
	before_each(function()
		git_mob.run_command = function() end
	end)

	it("gets coauthors", function()
		--- @return vim.SystemCompleted
		git_mob.run_command = function()
			return {
				stdout = [[
aa, Alice Anders, alice.anders@example.org
bb, Bob Barnes, bob.barnes@example.org
			]],
			}
		end

		eq(git_mob.get_coauthors(), {
			{ initials = "aa", name = "Alice Anders", email = "alice.anders@example.org" },
			{ initials = "bb", name = "Bob Barnes", email = "bob.barnes@example.org" },
		})
	end)
end)
