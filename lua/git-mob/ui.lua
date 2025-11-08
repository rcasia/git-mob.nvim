local ui = require("ascii-ui")

local api = require("git-mob.api")

local GitMob = { ui = {} }

local CoAuthorListItem = ui.createComponent("CoAuthorListItem", function(props)
	local author = props.author

	return {
		ui.blocks
			.Segment({
				content = ("%s     %s"):format(author.name, author.email),
				color = { bg = author.active and "Green" or nil },
				interactions = {
					SELECT = function() api.toggle_coauthor(author.initials) end,
				},
			})
			:wrap(),
	}
end, { author = "table" })

GitMob.ui.select_coauthors = function()
	local CoAuthorSelector = ui.createComponent("CoAuthorSelector", function()
		--- @type GitMob.Author[]
		local coauthors, set_coauthors = ui.hooks.useState(api.get_coauthors())

		return {
			ui.blocks.Segment({ content = "Select Coauthors" }):wrap(),
			vim.iter(coauthors):map(function(author) return CoAuthorListItem({ author = author }) end):totable(),
		}
	end)

	ui.mount(CoAuthorSelector)
end

return GitMob.ui
