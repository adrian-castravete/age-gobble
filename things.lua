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
		tgt = nil,
	}
	obj.__index = obj

	return obj
end

local Head = defaultSprite("head", 0)
function Head:mousepressed(s, x, y)
	self.tgt = {
		x = x/VP.scale,
		y = y/VP.scale,
		s = 0,
	}
end

function Head:mousereleased(s, x, y)
	self.tgt = nil
end

function Head:mousemoved(s, x, y)
	if self.tgt then
		self.tgt.x = x/VP.scale
		self.tgt.y = y/VP.scale
	end
end

local Tail = defaultSprite("tail", 16)

return {
	Head = Head,
	Tail = Tail,
}
