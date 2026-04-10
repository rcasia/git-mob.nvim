local git_mob = require("git-mob")

describe("setup", function()
	after_each(function()
		pcall(vim.api.nvim_del_user_command, "GitMobWho")
		pcall(vim.api.nvim_del_user_command, "GitMobSolo")
		pcall(vim.api.nvim_del_user_command, "GitMobSelect")
	end)

	it("registers :GitMobWho command", function()
		git_mob.setup()

		local cmds = vim.api.nvim_get_commands({})
		assert(cmds["GitMobWho"] ~= nil, "Expected :GitMobWho to be registered")
	end)

	it(":GitMobWho notifies with current mob members", function()
		local notifications = {}
		vim.notify = function(msg) table.insert(notifications, msg) end

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
		end

		git_mob.setup()
		vim.cmd("GitMobWho")

		assert(#notifications == 1, "Expected exactly one notification")
		assert(
			notifications[1] == "Alice Anders <alice.anders@example.org>\nBob Barnes <bob.barnes@example.org>",
			("Unexpected notification: %s"):format(notifications[1])
		)
	end)

	it(":GitMobWho notifies 'Solo' when no mob", function()
		local notifications = {}
		vim.notify = function(msg) table.insert(notifications, msg) end

		git_mob.api.run_command = function() return { stdout = { "" } } end

		git_mob.setup()
		vim.cmd("GitMobWho")

		assert(notifications[1] == "Solo", ("Unexpected notification: %s"):format(notifications[1]))
	end)
end)
