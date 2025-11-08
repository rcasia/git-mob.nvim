--- @generic T
--- @param ... T
--- @return Mono<T>
local function Mono(...)
	local v = { ... }

	--- @type Mono
	return {
		value = unpack(v),
		--- @generic T, U
		--- @param fn fun(value: T): U
		--- @return Mono<U>
		map = function(fn)
			return Mono(fn(unpack(v)))
		end,
		to_string = function()
			return ("Mono(%s)"):format(vim.inspect(v))
		end,
		chain = function(fn)
			return fn(unpack(v))
		end,
	}
end

return Mono
