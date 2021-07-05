Age = require("age")
VP = require("viewport")
lg = love.graphics
lg.setDefaultFilter("nearest", "nearest")

VP.setup()

function love.update(dt)
	lg.setCanvas(VP.canvas)
	lg.clear(clearColor or nil)
	Age.update(dt)
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

function love.mousepressed(x, y, button, isTouch)
	Age.message(nil, "head", "mousepressed", x, y)
end

function love.mousereleased(x, y, button, isTouch)
	Age.message(nil, "head", "mousereleased", x, y)
end

function love.mousemoved(x, y, dx, dy, isTouch)
	Age.message(nil, "head", "mousemoved", x, y)
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