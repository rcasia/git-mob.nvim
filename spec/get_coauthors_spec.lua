-- simple equality helper (no luassert needed)
local function eq(actual, expected)
	if not vim.deep_equal(actual, expected) then
		error(("Expected:\n%s\nBut got:\n%s"):format(vim.inspect(expected), vim.inspect(actual)), 2)
	end
end

local git_mob = require("git-mob")

describe("run_command", function()
	it("raises a Lua error when the command exits with a non-zero code", function()
		local ok, err = pcall(git_mob.api.run_command, { "git", "not-a-real-git-command" })
		assert(not ok, "Expected run_command to raise an error but it did not")
		assert(
			type(err) == "string" and err:find("not%-a%-real%-git%-command"),
			("Expected error message to mention the command, got: %s"):format(tostring(err))
		)
	end)

	it("calls on_done(nil) when command succeeds (async mode)", function()
		local result = "NOT_CALLED"
		git_mob.api.run_command({ "git", "--version" }, function(err) result = err end)
		vim.wait(1000, function() return result ~= "NOT_CALLED" end)
		assert(result == nil, ("Expected on_done(nil), got: %s"):format(tostring(result)))
	end)

	it("calls on_done(err) when command fails (async mode)", function()
		local result = "NOT_CALLED"
		git_mob.api.run_command({ "git", "not-a-real-git-command" }, function(err) result = err end)
		vim.wait(1000, function() return result ~= "NOT_CALLED" end)
		assert(
			type(result) == "string" and result:find("not%-a%-real%-git%-command"),
			("Expected on_done(err) mentioning the command, got: %s"):format(tostring(result))
		)
	end)
end)

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

	it("sets current mobbers", function()
		local cmds_executed = {}
		git_mob.api.run_command = function(cmd) cmds_executed[#cmds_executed + 1] = cmd end

		git_mob.api.set_current_mobbers({ "aa", "bb", "cc" })

		eq(cmds_executed[1], { "git-mob", "aa", "bb", "cc" })
		eq(#cmds_executed, 1)
	end)

	it("sets current mobbers to solo when empty", function()
		local cmds_executed = {}
		git_mob.api.run_command = function(cmd) cmds_executed[#cmds_executed + 1] = cmd end

		git_mob.api.set_current_mobbers({})

		eq(cmds_executed[1], { "git", "solo" })
		eq(#cmds_executed, 1)
	end)

	it("switches back to developing solo", function()
		local cmds_executed = {}
		git_mob.api.run_command = function(cmd) cmds_executed[#cmds_executed + 1] = cmd end

		git_mob.api.go_solo()

		eq(cmds_executed[1], { "git", "solo" })
		eq(#cmds_executed, 1)
	end)

	it("toggles coauthor active state", function()
		local cmds_executed = {}

		git_mob.api.run_command = function(cmd, on_done)
			cmds_executed[#cmds_executed + 1] = cmd

			if cmd[1] == "git-mob" and cmd[2] == "--list" then
				return {
					stdout = {
						"aa, Alice Anders, alice.anders@example.org",
						"bb, Bob Barnes, bob.barnes@example.org",
						"cc, Carl Carlson, carl.carlson@example.org",
						"",
					},
				}
			end

			if cmd[1] == "git-mob" then
				if on_done then on_done(nil) return end
				return {
					stdout = {
						"Alice Anders <alice.anders@example.org>",
						"Bob Barnes <bob.barnes@example.org>",
						"Carl Carlson <carl.carlson@example.org>",
						"",
					},
				}
			end
		end

		git_mob.api.toggle_coauthor("aa")

		eq(cmds_executed[#cmds_executed], { "git-mob", "bb", "cc" })
	end)

	it("toggles coauthor active state when only one left active goes solo", function()
		local cmds_executed = {}

		git_mob.api.run_command = function(cmd, on_done)
			cmds_executed[#cmds_executed + 1] = cmd

			if cmd[1] == "git-mob" and cmd[2] == "--list" then
				return {
					stdout = {
						"aa, Alice Anders, alice.anders@example.org",
						"bb, Bob Barnes, bob.barnes@example.org",
						"cc, Carl Carlson, carl.carlson@example.org",
						"",
					},
				}
			end

			if cmd[1] == "git-mob" then
				if on_done then on_done(nil) return end
				return {
					stdout = {
						"Alice Anders <alice.anders@example.org>",
						"",
					},
				}
			end

			if cmd[1] == "git" and cmd[2] == "solo" then
				if on_done then on_done(nil) return end
			end
		end

		git_mob.api.toggle_coauthor("aa")

		eq(cmds_executed[#cmds_executed], { "git", "solo" })
	end)

	it("calls on_done after toggling coauthor (async mode)", function()
		local done_err = "NOT_CALLED"

		git_mob.api.run_command = function(cmd, on_done)
			if cmd[1] == "git-mob" and cmd[2] == "--list" then
				return {
					stdout = {
						"aa, Alice Anders, alice.anders@example.org",
						"bb, Bob Barnes, bob.barnes@example.org",
						"",
					},
				}
			end
			-- git-mob with no args: current mob (only bb active)
			if cmd[1] == "git-mob" and not on_done then
				return { stdout = { "Bob Barnes <bob.barnes@example.org>", "" } }
			end
			-- final async dispatch: git-mob aa bb
			if cmd[1] == "git-mob" and on_done then
				on_done(nil)
				return
			end
		end

		git_mob.api.toggle_coauthor("aa", function(err) done_err = err end)

		assert(done_err == nil, ("Expected on_done(nil), got: %s"):format(tostring(done_err)))
	end)

	it("gets current mob members", function()
		git_mob.api.run_command = function(cmd)
			if cmd[1] == "git-mob" then
				return {
					stdout = {
						"Alice Anders <alice.anders@example.org>",
						"Bob Barnes <bob.barnes@example.org>",
						"",
					},
				}
			end
			error("Unexpected command: " .. table.concat(cmd, " "))
		end

		local result = git_mob.api.get_current_mob()
		eq(result, {
			{ name = "Alice Anders", email = "alice.anders@example.org" },
			{ name = "Bob Barnes", email = "bob.barnes@example.org" },
		})
	end)
end)
