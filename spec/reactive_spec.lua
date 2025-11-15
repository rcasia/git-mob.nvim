local Mono = require("git-mob.types.mono2")

local function eq(actual, expected)
	if not vim.deep_equal(actual, expected) then
		error(("Expected:\n%s\nBut got:\n%s"):format(vim.inspect(expected), vim.inspect(actual)), 2)
	end
end

describe("Reactive Mono", function()
	it("creates a mono from value", function()
		--
		eq(42, Mono.from(42):block())
	end)

	it("creates a mono that can map", function()
		eq(41, Mono.from(42):map(function(n) return n - 1 end):block())
	end)

	it("creates a mono that can flatMap", function()
		eq(
			41,
			Mono
				--
				.from(42)
				:flatmap(function(n) return Mono.from(n - 1) end)
				:block()
		)
	end)

	it("can be extended multiple times", function()
		local my_mono = Mono.from(42)

		eq(42, my_mono:block())
		eq(41, my_mono:map(function(n) return n - 1 end):block())
		eq(43, my_mono:map(function(n) return n + 1 end):block())
	end)

	it("handles errors", function()
		--
		eq(
			0,
			Mono
				--
				.from(42)
				:map(function() error("boom") end)
				:on_error(function() return 0 end)
				:block()
		)
	end)
end)
