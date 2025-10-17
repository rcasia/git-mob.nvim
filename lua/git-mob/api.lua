local Author = require("git-mob.types.author")
local AuthorDetails = require("git-mob.types.author_details")

local GitMob = {
	api = {
		--- @param cmd string[]
		--- @return vim.SystemCompleted
		run_command = function(cmd)
			return vim.system(cmd):wait()
		end,
	},
}

--- @return GitMob.Author[]
GitMob.api.get_coauthors = function()
	local result1 = GitMob.api.run_command({ "git-mob", "--list" })
	local result2 = GitMob.api.run_command({ "git-mob" })

	local coauthors_details = AuthorDetails.from_lines(vim.split(result1.stdout, "\n"))
	local active_authors_details = vim.iter(vim.split(result2.stdout, "\n"))
		:filter(function(line)
			return line ~= ""
		end)
		:map(function(line)
			local name, email = line:match("^(.-) <%s*(.-)%s*>$")
			return { name = name, email = email }
		end)
		:totable()

	return vim.iter(coauthors_details)
		:map(function(coauthor_detail)
			local is_active = vim.iter(active_authors_details):any(function(detail)
				return detail.email == coauthor_detail.email
			end)

			return Author.from(coauthor_detail, is_active)
		end)
		:totable()
end

return GitMob.api
