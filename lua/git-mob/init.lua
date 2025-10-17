--- @class GitMob.Author
--- @field active boolean | nil
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

	--- @param lines string[]
	--- @return GitMob.Author[]
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

	local all_authors = authors_from_lines(vim.split(result1.stdout, "\n"))
	local active_authors = authors_from_lines(vim.split(result2.stdout, "\n"))

	return vim.iter(all_authors)
		:map(function(author)
			author.active = vim.iter(active_authors):any(function(active_author)
				return active_author.initials == author.initials
			end)

			return author
		end)
		:totable()
end

return GitMob
