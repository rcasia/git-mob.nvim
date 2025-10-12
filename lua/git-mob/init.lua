--- @class GitMob.Author
--- @field initials string
--- @field name string
--- @field email string

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
	--- @return GitMob.Author
	local function author_from_string(str)
		local initials, name, email = unpack(vim.split(str, ", "))

		return { initials = initials, name = name, email = email }
	end

	local result = GitMob.run_command({ "git-mob", "--list" })

	return vim
		.iter(vim.split(result.stdout, "\n"))
		:map(vim.trim)
		:filter(function(line)
			return line ~= ""
		end)
		:map(author_from_string)
		--
		:totable()
end

return GitMob
