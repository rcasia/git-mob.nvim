--- @class GitMob.Author
--- @field active boolean
--- @field details GitMob.AuthorDetails
local Author = {}
Author.__index = Author

--- @param active boolean
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

return Author
