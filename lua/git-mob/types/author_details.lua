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

--- Parse a coauthor line like:
---   aa, Alice Anders, alice.anders@example.org
---
--- @param str string
--- @return GitMob.AuthorDetails
function AuthorDetails.from_string(str)
	local initials, name, email = unpack(vim.split(str, ", "))

	return AuthorDetails.from({ initials = initials, name = name, email = email })
end

--- @param lines string[]
--- @return GitMob.AuthorDetails[]
function AuthorDetails.from_lines(lines)
	return vim
		.iter(lines)
		:map(vim.trim)
		:filter(function(line)
			return line ~= ""
		end)
		:map(AuthorDetails.from_string)
		--
		:totable()
end

return AuthorDetails
