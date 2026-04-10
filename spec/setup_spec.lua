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
end)
