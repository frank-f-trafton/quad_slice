local quadSlice = require("quad_slice")

local image = love.graphics.newImage("demo_res/9s_image.png")

-- (The 9slice starts at at 32x32, and has 64x64 corner tiles and an 8x8 center.)
local slice = quadSlice.new9Slice(image, 32,32, 64,64, 8,8, 64,64) -- x,y, w1,h1, w2,h2, w3,h3

function love.draw()
	local mx, my = love.mouse.getPosition()

	quadSlice.draw(slice, 32, 32, mx - 32, my - 32) -- x, y, w, h
end
