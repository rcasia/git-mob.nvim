local AuthorDetails = require("git-mob.types.author_details")

local GitMob = {
	api = {
		--- @param cmd string[]
		--- @return { stdout: string[] }
		run_command = function(cmd)
			local result = vim.system(cmd):wait()
			if result.code ~= 0 then
				error(
					("git-mob: command failed: %s\n%s"):format(
						table.concat(cmd, " "),
						result.stderr or ""
					)
				)
			end
			return { stdout = vim.split(result.stdout, "\n") }
		end,
	},
}

--- @return fun(email: string): boolean
GitMob.api.is_coauthor_active = function()
	local stdout = GitMob.api.run_command({ "git-mob" }).stdout
	return function(email)
		return vim.iter(stdout):any(function(line)
			local _, line_email = line:match("^(.-) <%s*(.-)%s*>$")
			return line_email == email
		end)
	end
end

--- @return { initials: string, name: string, email: string, active: boolean }[]
GitMob.api.get_coauthors = function()
	local lines = GitMob.api.run_command({ "git-mob", "--list" }).stdout
	local is_active = GitMob.api.is_coauthor_active()
	return vim.iter(AuthorDetails.from_lines(lines))
		:map(function(d)
			return { initials = d.initials, name = d.name, email = d.email, active = is_active(d.email) }
		end)
		:totable()
end

--- @param initials_list string[]
GitMob.api.set_current_mobbers = function(initials_list)
	if #initials_list == 0 then
		GitMob.api.go_solo()
		return
	end
	GitMob.api.run_command(vim.list_extend({ "git-mob" }, initials_list))
end

--- @param initials string
GitMob.api.toggle_coauthor = function(initials)
	local active_initials = vim.iter(GitMob.api.get_coauthors())
		:map(function(c)
			if c.initials == initials then c.active = not c.active end
			return c
		end)
		:filter(function(c) return c.active end)
		:map(function(c) return c.initials end)
		:totable()
	GitMob.api.set_current_mobbers(active_initials)
end

--- @return { name: string, email: string }[]
GitMob.api.get_current_mob = function()
	return vim.iter(GitMob.api.run_command({ "git-mob" }).stdout)
		:filter(function(line) return line ~= "" end)
		:map(function(line)
			local name, email = line:match("^(.-) <%s*(.-)%s*>$")
			return { name = name, email = email }
		end)
		:filter(function(d) return d.name ~= nil end)
		:totable()
end

GitMob.api.go_solo = function() GitMob.api.run_command({ "git", "solo" }) end

return GitMob.api
