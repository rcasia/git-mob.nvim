local ui = require("ascii-ui")

local api = require("git-mob.api")

local GitMob = { ui = {} }

GitMob.ui.select_coauthors = function()
	local CoAuthorSelector = ui.createComponent("CoAuthorSelector", function()
		--- @type GitMob.Author[]
		local coauthors, set_coauthors = ui.hooks.useState(api.get_coauthors())

		return {
			ui.blocks.Segment({ content = "Select Coauthors" }):wrap(),
			vim
				.iter(coauthors)
				--- @param author GitMob.Author
				:map(function(author)
					return ui.blocks
						.Segment({
							content = ("%s     %s"):format(author.details.name, author.details.email),
							color = { bg = author.active and "Green" or nil },
							interactions = {
								SELECT = function() end,
							},
						})
						:wrap()
				end)
				:totable(),
		}
	end)

	ui.mount(CoAuthorSelector)
end

return GitMob.ui
