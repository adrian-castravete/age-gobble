function defaultSprite(name, y)
	local _spr = SG("assets/gobble.png", {
		default = {
			x = 0,
			y = y,
			w = 16,
			h = 16,
			c = 8,
			n = 8,
		}
	})
	local obj = {
		name = name,
		spr = _spr,
		qs = _spr.quads.default,
	}
	obj.__index = obj

	return obj
end

return {
	Head = defaultSprite("head", 0),
	Tail = defaultSprite("tail", 16),
}
