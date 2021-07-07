local _spr = SG("assets/gobble.png", {
	default = {
		x = 0,
		y = 0,
		w = 16,
		h = 16,
		c = 8,
		n = 8,
	},
	defaultTail = {
		x = 0,
		y = 16,
		w = 16,
		h = 16,
		c = 8,
		n = 8,
	},
})

local Piece = {
	name = name,
	spr = _spr,
	qs = _spr.quads.default,
	tgt = nil,
	tailPositions = {},
}

function Piece:draw()
	local img = self.spr.image or error("Unavailable Image", 2)
	local x, y = math.floor(self.x or 0), math.floor(self.y or 0)
	local w, h = self.w or 16, self.h or 16
	local wo, ho = -bit.rshift(w, 1), -bit.rshift(h, 1)
	local q = self.q
	if not q and self.r then
		q = self.qs[self.r]
	end

	lg.push()
	lg.translate(wo, ho)
	if q then
		lg.draw(img, q, x, y)
	else
		lg.draw(img, x, y)
	end
	lg.pop()
end

function Piece:update(dt)
	self:draw()
end

function Piece:pushPosition()
	local tp = self.tailPositions
	if #tp < 16 then
		table.insert(tp, {self.x, self.y})
		return
	end

	for i=1, 15 do
		tp[i][1] = tp[i+1][1]
		tp[i][2] = tp[i+1][2]
	end
	tp[16][1] = self.x
	tp[16][2] = self.y
	if self.tailElem then
		self:message(self.tailElem, "movedPosition", tp[1][1], tp[1][2])
	end
end

function Piece:tailFree(tail)
	if self.tailElem == tail then return end

	if self.tailElem then
		self:message(self.tailElem, "tailFree", tail)
		return
	end

	self.tailElem = tail
	self:message(tail, "headAttach", self)
end



local Head = Age.clone(Piece)

function Head:update(dt)
	local e = self

	if e.tgt then
		self:pushPosition()
		local s = e.tgt.s
		if s < 5 then
			s = s + 1
		end
		e.tgt.s = s
		s = math.max(1,
			math.min(s,
				math.max(
					math.abs(e.tgt.x - e.x),
					math.abs(e.tgt.y - e.y)
				)
			)
		)
		local dx = math.floor(e.tgt.x) - math.floor(e.x)
		local dy = math.floor(e.tgt.y) - math.floor(e.y)
		local d = dt * s * 8
		if dx < 0 then
			e.x = e.x - d
		elseif dx > 0 then
			e.x = e.x + d
		end
		if dy < 0 then
			e.y = e.y - d
		elseif dy > 0 then
			e.y = e.y + d
		end
		if dx == 0 and dy < 0 then
			e.r = 1
		elseif dx > 0 and dy < 0 then
			e.r = 2
		elseif dx > 0 and dy == 0 then
			e.r = 3
		elseif dx > 0 and dy > 0 then
			e.r = 4
		elseif dx == 0 and dy > 0 then
			e.r = 5
		elseif dx < 0 and dy > 0 then
			e.r = 6
		elseif dx < 0 and dy == 0 then
			e.r = 7
		elseif dx < 0 and dy < 0 then
			e.r = 8
		end
	end

	e:message("tail", "headMoved", e)

	self:draw()
end

function Head:mousepressed(x, y)
	self.tgt = {
		x = (x - VP.offsetX) / VP.scale,
		y = (y - VP.offsetY) / VP.scale,
		s = 0,
	} end
function Head:mousereleased(x, y)
	self.tgt = nil
end

function Head:mousemoved(x, y)
	if self.tgt then
		self.tgt.x = (x - VP.offsetX) / VP.scale
		self.tgt.y = (y - VP.offsetY) / VP.scale
	end
end



local Tail = Age.clone(Piece)

function Tail:init()
	self.qs = self.spr.quads.defaultTail
end

function Tail:headMoved(head)
	if self.headElem then return end

	local dx, dy = head.x - self.x, head.y - self.y
	if dx*dx + dy*dy >= 256 then return end

	self:message(head, "tailFree", self)
end

function Tail:movedPosition(x, y)
	self:pushPosition()
	self.x = x
	self.y = y
end

function Tail:autoMove(dt)
	local e = self
	local a = (e.r - 1) * math.pi / 4
	e.x = e.x + math.sin(a) * dt * 8
	e.y = e.y - math.cos(a) * dt * 8

	if e.x < 0 then e.x = 0 end
	if e.y < 0 then e.y = 0 end
	if e.x > 319 then e.x = 319 end
	if e.y > 239 then e.y = 239 end

	if math.random() < 0.01 then
		e.r = 1 + math.floor(math.random() * 8)
	end
end

function Tail:update(dt)
	if not self.headElem then
		self:autoMove(dt)
	end

	self:draw()
end

function Tail:headAttach(head)
	self.headElem = head
end

Age.template("tail", Tail)
Age.template("head", Head)
