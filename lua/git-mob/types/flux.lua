local Mono = require("git-mob.types.mono")

--- @class Flux
--- @field private monos Mono[]
local Flux = {}
Flux.__index = Flux

function Flux.from(list)
	local monos = {}
	for i, value in ipairs(list) do
		monos[i] = Mono.from(value)
	end
	return setmetatable({ monos = monos }, Flux)
end

function Flux:to_list()
	local list = {}
	for i, mono in ipairs(self.monos) do
		list[i] = mono:block()
	end
	return list
end

function Flux:map(mapper_fn)
	for i, mono in ipairs(self.monos) do
		self.monos[i] = mono:map(mapper_fn)
	end
	return self
end

return Flux
