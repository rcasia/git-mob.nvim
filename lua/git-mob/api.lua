local AuthorDetails = require("git-mob.types.author_details")
local Mono = require("git-mob.types.mono")

local GitMob = {
	api = {
		--- @param cmd string[]
		--- @return { stdout: string[] }
		run_command = function(cmd)
			local result = vim.system(cmd):wait()

			return {
				stdout = vim.split(result.stdout, "\n"),
			}
		end,
	},
}

--- @return fun(email: string): boolean
GitMob.api.is_coauthor_active = function()
	return Mono(GitMob.api.run_command({ "git-mob" }))
		.prop("stdout")
		.map(function(stdout)
			return vim.iter(stdout)
				:map(function(line)
					local name, email = line:match("^(.-) <%s*(.-)%s*>$")
					return { name = name, email = email }
				end)
				:totable()
		end)
		.map(function(data)
			return function(email)
				return vim.iter(data):any(function(d)
					return d.email == email
				end)
			end
		end).value
end

--- @return { initials: string, name: string, email: string, active: boolean }[]
GitMob.api.get_coauthors = function()
	return Mono(GitMob.api.run_command({ "git-mob", "--list" }))
		.prop("stdout")
		.map(AuthorDetails.from_lines)
		.map(function(coauthors_details)
			return vim.iter(coauthors_details)
				:map(function(coauthor_detail)
					return {
						initials = coauthor_detail.initials,
						name = coauthor_detail.name,
						email = coauthor_detail.email,
						active = GitMob.api.is_coauthor_active()(coauthor_detail.email),
					}
				end)
				:totable()
		end).value
end

--- @param initials_list string[]
GitMob.api.set_current_mobbers = function(initials_list)
	local cmd = { "git-mob" }
	for _, initials in ipairs(initials_list) do
		table.insert(cmd, initials)
	end

	GitMob.api.run_command(cmd)
end

return GitMob.api
