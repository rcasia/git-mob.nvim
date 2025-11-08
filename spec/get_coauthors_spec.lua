-- simple equality helper (no luassert needed)
local function eq(actual, expected)
	if not vim.deep_equal(actual, expected) then
		error(("Expected:\n%s\nBut got:\n%s"):format(vim.inspect(expected), vim.inspect(actual)), 2)
	end
end

local git_mob = require("git-mob")

describe("get coauthors feature", function()
	before_each(function()
		git_mob.api.run_command = function() end
	end)

	it("gets coauthors", function()
		git_mob.api.run_command = function(cmd)
			if cmd[1] == "git-mob" and cmd[2] == "--list" then
				return {
					stdout = {
						"aa, Alice Anders, alice.anders@example.org",
						"bb, Bob Barnes, bob.barnes@example.org",
						"",
					},
				}
			end

			if cmd[1] == "git-mob" then
				return {
					stdout = {
						"Alice Anders <alice.anders@example.org>",
						"Carl Carlson <carl.carlson@example.org>",
						"",
					},
				}
			end

			error("Unexpected command: " .. table.concat(cmd, " "))
		end

		local result = git_mob.api.get_coauthors()
		eq(result, {
			{ active = true, initials = "aa", name = "Alice Anders", email = "alice.anders@example.org" },
			{ active = false, initials = "bb", name = "Bob Barnes", email = "bob.barnes@example.org" },
		})
	end)

	it("set current mobbers", function()
		local cmds_executed = {}
		git_mob.api.run_command = function(cmd)
			cmds_executed[#cmds_executed + 1] = cmd
		end

		git_mob.api.set_current_mobbers({ "aa", "bb", "cc" })

		eq(cmds_executed[1], { "git-mob", "aa", "bb", "cc" })
		eq(#cmds_executed, 1)
	end)
end)
