--- @class GitMob.Author
--- @field active boolean
--- @field details GitMob.AuthorDetails
local Author = {}
Author.__index = Author

--- @param is_active boolean
--- @param details GitMob.AuthorDetails
--- @return GitMob.Author
function Author.from(details, active)
	vim.validate({
		active = { active, "boolean" },
		details = { details, "table" },
	})
	return setmetatable({
		details = details,
		active = active,
	}, Author)
end

--- @return table<string, any>
function Author:to_table()
	return {
		active = self.active,
		initials = self.details.initials,
		name = self.details.name,
		email = self.details.email,
	}
end

--- @class GitMob.AuthorDetails
--- @field initials string
--- @field name string
--- @field email string
local AuthorDetails = {}
AuthorDetails.__index = AuthorDetails

--- @param details GitMob.AuthorDetails
--- @return GitMob.AuthorDetails
function AuthorDetails.from(details)
	vim.validate({ details = { details, "table" } })
	vim.validate({
		initials = { details.initials, "string" },
		name = { details.name, "string" },
		email = { details.email, "string" },
	})
	return setmetatable({
		initials = vim.trim(details.initials),
		name = vim.trim(details.name),
		email = vim.trim(details.email),
	}, AuthorDetails)
end

local GitMob = {
	--- @param cmd string[]
	--- @return vim.SystemCompleted
	run_command = function(cmd)
		return vim.system(cmd):wait()
	end,
}

--- @return GitMob.Author[]
GitMob.get_coauthors = function()
	--- Parse a coauthor line like:
	---   aa, Alice Anders, alice.anders@example.org
	---
	--- @param str string
	--- @return GitMob.AuthorDetails
	local function author_from_string(str)
		local initials, name, email = unpack(vim.split(str, ", "))

		return AuthorDetails.from({ initials = initials, name = name, email = email })
	end

	--- @param lines string[]
	--- @return GitMob.AuthorDetails[]
	local function authors_from_lines(lines)
		return vim
			.iter(lines)
			:map(vim.trim)
			:filter(function(line)
				return line ~= ""
			end)
			:map(author_from_string)
			--
			:totable()
	end

	local result1 = GitMob.run_command({ "git-mob", "--list" })
	local result2 = GitMob.run_command({ "git-mob" })

	local coauthors_details = authors_from_lines(vim.split(result1.stdout, "\n"))
	local active_authors_details = authors_from_lines(vim.split(result2.stdout, "\n"))

	return vim.iter(coauthors_details)
		:map(function(coauthor_detail)
			local is_active = vim.iter(active_authors_details):any(function(detail)
				return detail.initials == coauthor_detail.initials
			end)

			return Author.from(coauthor_detail, is_active)
		end)
		:totable()
end

return GitMob
