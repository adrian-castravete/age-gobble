require("things")

local function spawn(t)
	local e = Age.entity(t, {
		x = math.random() * 320,
		y = math.random() * 240,
		r = 1 + math.floor(math.random() * 8),
	})
end

function demo()
	for i=1, 15 do
		spawn("tail")
	end
	spawn("head")
end

return {
	demo = demo,
}
