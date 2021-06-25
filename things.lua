function playerPiece(name, y)
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
		tailPositions = {},
	}
	obj.__index = obj

	return obj
end

local Head = playerPiece("head", 0)
function Head:mousepressed(s, x, y)
	self.tgt = {
		x = (x - VP.offsetX) / VP.scale,
		y = (y - VP.offsetY) / VP.scale,
		s = 0,
	}
end

function Head:mousereleased(s, x, y)
	self.tgt = nil
end

function Head:mousemoved(s, x, y)
	if self.tgt then
		self.tgt.x = (x - VP.offsetX) / VP.scale
		self.tgt.y = (y - VP.offsetY) / VP.scale
	end
end

function Head:tailAttach(s)
	self.tailElem = s
end

local Tail = playerPiece("tail", 16)
function Tail:headTouch(s)
	print(tostring(self), tostring(s))
	if self.tailElem then
		E.message(self, self.tailElem, "headTouch")
		return
	end

	self.headElem = s
	E.message(self, s, "tailAttach")
end

function Tail:tailAttach(s)
	self.tailElem = s
end

function Tail:movedPosition(s, x, y)
	self.x = x
	self.y = y
end

return {
	Head = Head,
	Tail = Tail,
}
