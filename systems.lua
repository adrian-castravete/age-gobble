E.S("spr", function (sys, e)
	local img = e.spr.image or error("Unavailable Image", 2)
	local x, y = math.floor(e.x or 0), math.floor(e.y or 0)
	local w, h = e.w or 16, e.h or 16
	local wo, ho = -bit.rshift(w, 1), -bit.rshift(h, 1)
	local q = e.q
	if not q and e.r then
		q = e.qs[e.r]
	end

	lg.push()
	lg.translate(wo, ho)
	if q then
		lg.draw(img, q, x, y)
	else
		lg.draw(img, x, y)
	end
	lg.pop()
end)

local function pushPosition(e)
	local tp = e.tailPositions
	if #tp < 16 then
		table.insert(tp, {e.x, e.y})
		return
	end

	for i=1, 15 do
		tp[i][1] = tp[i+1][1]
		tp[i][2] = tp[i+1][2]
	end
	tp[16][1] = e.x
	tp[16][2] = e.y
	if e.tailElem then
		E.message(e, e.tailElem, "movedPosition", tp[1][1], tp[1][2])
	end
end

E.S("head", function (sys, e, dt)
	if e.tgt then
		pushPosition(e)
		local s = e.tgt.s
		if s < 8 then
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

	E.map("tail", function(o)
		local dx, dy = e.x - o.x, e.y - o.y
		if math.sqrt(dx*dx + dy*dy) < 16 then
			E.message(e, o, "headTouch")
		end
	end)
end)

local function autoMove(e, dt)
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

E.S("tail", function (sys, e, dt)
	pushPosition(e)

	if not e.headElem then
		autoMove(e, dt)
	end
end)
