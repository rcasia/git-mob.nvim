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

--- @class Mono
--- @field value any
--- @field map fun(fn: fun(...: any): any): Mono<any>
--- @field to_string fun(): string
--- @field chain fun(fn: fun(x: any): Mono<any>): Mono<any>

-- - @return GitMob.Author[]
GitMob.api.get_coauthors = function()
	local is_active = Mono(GitMob.api.run_command({ "git-mob" }))
		--
		.map(function(result)
			return vim.iter(result.stdout)
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
		end)
		.value

	return Mono(GitMob.api.run_command({ "git-mob", "--list" }))
		.map(function(result)
			return AuthorDetails.from_lines(result.stdout)
		end)
		.map(function(coauthors_details)
			return vim.iter(coauthors_details)
				:map(function(coauthor_detail)
					return {
						initials = coauthor_detail.initials,
						name = coauthor_detail.name,
						email = coauthor_detail.email,
						active = is_active(coauthor_detail.email),
					}
				end)
				:totable()
		end).value
end

return GitMob.api
