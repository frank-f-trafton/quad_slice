local quadSlice = require("quad_slice")

local image = love.graphics.newImage("demo_res/9s_image.png")

-- (The 9-slice starts at at 32x32, and has 64x64 corner tiles and an 8x8 center.)
local slice = quadSlice.newSlice(32,32, 64,64, 8,8, 64,64, image:getWidth(), image:getHeight())

function love.draw()
	local mx, my = love.mouse.getPosition()

	slice:draw(image, 32, 32, mx - 32, my - 32)
end
