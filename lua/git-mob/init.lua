local GitMob = {}

GitMob.api = require("git-mob.api")
GitMob.ui = require("git-mob.ui")

GitMob.setup = function()
	vim.api.nvim_create_user_command("GitMobWho", function()
		local mob = GitMob.api.get_current_mob()
		local lines = vim.iter(mob):map(function(a) return ("%s <%s>"):format(a.name, a.email) end):totable()
		vim.notify(#lines > 0 and table.concat(lines, "\n") or "Solo", vim.log.levels.INFO)
	end, { desc = "Show current mob" })

	vim.api.nvim_create_user_command("GitMobSolo", function()
		GitMob.api.go_solo()
	end, { desc = "Go solo (clear all co-authors)" })

	vim.api.nvim_create_user_command("GitMobSelect", function()
		GitMob.ui.select_coauthors()
	end, { desc = "Interactively select co-authors" })
end

return GitMob
