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

return AuthorDetails
