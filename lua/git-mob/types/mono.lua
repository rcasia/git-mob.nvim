--- @class Mono
--- @field value any
--- @field map fun(fn: fun(...: any): any): Mono<any>
--- @field to_string fun(): string
--- @field chain fun(fn: fun(x: any): Mono<any>): Mono<any>
--- @field prop fun(key: any): Mono<any>

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
		prop = function(key)
			return Mono(v[1][key])
		end,
	}
end

return Mono
