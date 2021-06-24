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

E.S("head", function (sys, e, dt)
end)

E.S("tail", function (sys, e, dt)
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
end)
