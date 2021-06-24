E = require("age")
VP = require("viewport")
lg = love.graphics
lg.setDefaultFilter("nearest", "nearest")

VP.setup()

function love.update(dt)
	lg.setCanvas(VP.canvas)
	--lg.clear(1/3, 2/3, 1)
	E.update(dt)
	lg.setCanvas()
end

function love.resize(w, h)
	VP.resize(w, h)
end

function love.keyreleased(key)
	if key == "escape" then
		love.event.quit()
	end
end

love.draw = VP.draw

local spritesheet = require("spritesheet")
function SG(fname, qg)
	return spritesheet.build {
		fileName = fname,
		quadGen = qg,
	}
end

local worlds = require("worlds")
worlds.demo()