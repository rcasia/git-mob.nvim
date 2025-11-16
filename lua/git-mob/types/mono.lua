--- @class Mono<T>
--- @field private _thunk function
local Mono = {}
Mono.__index = Mono

--- @generic T
--- @param value T
--- @return Mono<T>
function Mono.from(value)
	return setmetatable({ _thunk = function() return value end }, Mono)
end

--- @generic T
--- @param fn fun(): T
--- @return Mono<T>
function Mono.defer(fn) return setmetatable({ _thunk = fn }, Mono) end

--- @generic T
--- @param self Mono<T>
--- @return T
function Mono:block() return self._thunk() end

--- @generic T, U
--- @param mapper_fn fun(value: T): U
--- @return Mono<U>
function Mono:map(mapper_fn)
	return Mono.defer(function()
		local value = self._thunk()
		return mapper_fn(value)
	end)
end

--- @param mapper_fn fun(value: any): Mono
--- @return Mono
function Mono:flatmap(mapper_fn)
	return Mono.defer(function()
		local value = self._thunk()
		return mapper_fn(value):block()
	end)
end

--- @param mapper_fn fun(value: any): Flux
--- @return Flux
function Mono:flat_map_many(mapper_fn)
	local value = self._thunk()
	return mapper_fn(value)
end

function Mono:on_error(error_fn)
	return Mono.defer(function()
		local ok, result = pcall(self._thunk)
		if ok then
			return result
		else
			return error_fn(result)
		end
	end)
end

return Mono
