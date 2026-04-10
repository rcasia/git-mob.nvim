local api = require("git-mob.api")

local GitMob = { ui = {} }

local ns = vim.api.nvim_create_namespace("git-mob")

--- @param author { initials: string, name: string, email: string, active: boolean }
--- @return string
local function format_line(author)
	local marker = author.active and "[*]" or "[ ]"
	return ("%s %s  %s  <%s>"):format(marker, author.initials, author.name, author.email)
end

--- @param buf integer
--- @param coauthors { initials: string, name: string, email: string, active: boolean }[]
local function render(buf, coauthors)
	vim.bo[buf].modifiable = true
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.iter(coauthors):map(format_line):totable())
	vim.bo[buf].modifiable = false

	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
	for i, author in ipairs(coauthors) do
		if author.active then vim.api.nvim_buf_add_highlight(buf, ns, "DiffAdd", i - 1, 0, -1) end
	end
end

--- @return { buf: integer, win: integer }|nil
GitMob.ui.select_coauthors = function()
	local ok, coauthors = pcall(api.get_coauthors)
	if not ok then
		vim.notify(tostring(coauthors), vim.log.levels.ERROR)
		return nil
	end
	local buf = vim.api.nvim_create_buf(false, true)
	render(buf, coauthors)

	local width = 60
	local height = math.max(#coauthors, 1)
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = math.max(0, math.floor((vim.o.lines - height) / 2)),
		col = math.max(0, math.floor((vim.o.columns - width) / 2)),
		style = "minimal",
		border = "rounded",
		title = " git mob ",
		title_pos = "center",
	})

	vim.keymap.set("n", "<CR>", function()
		local cursor = vim.api.nvim_win_get_cursor(0)
		local line = vim.api.nvim_buf_get_lines(buf, cursor[1] - 1, cursor[1], false)[1]
		local initials = line:match("^%[.%] (%S+)")
		if initials then
			for _, c in ipairs(coauthors) do
				if c.initials == initials then c.active = not c.active end
			end
			render(buf, coauthors)
			api.toggle_coauthor(initials, function(err)
				if err then vim.notify(err, vim.log.levels.ERROR) end
			end)
		end
	end, { buffer = buf, nowait = true })

	for _, key in ipairs({ "q", "<Esc>" }) do
		vim.keymap.set("n", key, function()
			vim.api.nvim_win_close(win, true)
		end, { buffer = buf, nowait = true })
	end

	return { buf = buf, win = win }
end

return GitMob.ui
