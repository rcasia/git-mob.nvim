--- @module "luassert"

local eq = assert.are.same

local git_mob = require("git-mob")

describe("get coauthors feature", function()
	it("gets coauthors", function()
		eq({}, git_mob.get_coauthors())
	end)
end)
