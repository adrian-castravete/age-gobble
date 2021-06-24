require("systems")
local T = require("things")
local function spawn(t)
	local e = E.E(t)
	e.x = math.random() * 320
	e.y = math.random() * 240
	e.r = 1 + math.floor(math.random() * 8)
end

function demo()
	for i=1, 15 do
		spawn(T.Tail)
	end
	spawn(T.Head)
end

return {
	demo = demo,
}
