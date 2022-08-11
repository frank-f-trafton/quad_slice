--[[
	Tests QuadSlice functions.
--]]

local quadSlice = require("quad_slice")

local image1 = love.graphics.newImage("demo_res/9s_test1.png")
image1:setFilter("nearest", "nearest")
local slice1 = quadSlice.new9Slice(image1, 8,8, 3,3, 2,2, 3,3)

local image2 = love.graphics.newImage("demo_res/9s_test2.png")
image2:setFilter("linear", "linear")
local slice2 = quadSlice.new9Slice(image2, 8,8, 3,3, 2,2, 3,3)

local image3 = love.graphics.newImage("demo_res/9s_test3.png")
image3:setFilter("nearest", "nearest")
local slice3 = quadSlice.new9Slice(image3, 0,0, 32,32, 8,8, 32,32)

local image_mir = love.graphics.newImage("demo_res/9s_mir.png")
image_mir:setFilter("nearest", "nearest")
image_mir:setWrap("mirroredrepeat", "mirroredrepeat") -- <- Important
local slice_mir_none = quadSlice.new9Slice(image_mir, 0,0, 32,32, 32,32, 32,32)
local slice_mir_h = quadSlice.new9SliceMirrorH(image_mir, 0,0, 32,32, 32,32, 32)
local slice_mir_v = quadSlice.new9SliceMirrorV(image_mir, 0,0, 32,32, 32,32, 32)
local slice_mir_hv = quadSlice.new9SliceMirrorHV(image_mir, 0,0, 32,32, 32,32)

local batch1 = love.graphics.newSpriteBatch(image_mir) -- tests batch:add()

local batch2 = love.graphics.newSpriteBatch(image_mir) -- tests batch:set() with hollow == false
quadSlice.batchAdd(batch2, slice_mir_none, 0, 0, 96, 96, false)

local batch3 = love.graphics.newSpriteBatch(image_mir) -- tests batch:set() with hollow == true
quadSlice.batchAdd(batch3, slice_mir_none, 0, 0, 96, 96, true)


-- Too much stuff to display on one screen :(
local page = 1


function love.keypressed(kc, sc, rep)
	if sc == "escape" then
		love.event.quit()
		return

	-- Page selection.
	elseif sc == "1" or sc == "2" then
		page = tonumber(sc)
	end
end


--function love.update(dt)


-- Helper for printing text to the display.
local function label(x, y, text)

	love.graphics.push("all")

	love.graphics.origin()
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.print(text, x, y)

	love.graphics.pop()
end


function love.draw()

	local demo_time = love.timer.getTime()
	local demo_w, demo_h
	local mx, my = love.mouse.getPosition()

	if page == 1 then
		love.graphics.push("all")

		label(8, 0, "scaled, nearest")

		demo_w = math.floor(32*2 + math.cos(demo_time) * 32)
		demo_h = math.floor(32*2 + math.sin(demo_time / 1.1) * 32)

		love.graphics.scale(3, 3)
		quadSlice.draw(slice1, 8, 8, demo_w, demo_h)

		love.graphics.pop()

		love.graphics.push("all")

		label(384, 0, "linear interp.")

		demo_w = math.floor(128*2 + math.cos(demo_time) * 64)
		demo_h = math.floor(128*2 + math.sin(demo_time / 1.1) * 64)

		quadSlice.draw(slice2, 384, 24, demo_w, demo_h)

		love.graphics.pop()

		love.graphics.push("all")

		label(mx - 24, my - 24, "hollow center tile")

		demo_w = math.floor(128*2 + math.cos(demo_time + math.pi/4) * 64)
		demo_h = math.floor(128*2 + math.sin((demo_time / 1.1) + math.pi/4) * 64)

		love.graphics.setColor(0, 0, 1, 0.5)

		love.graphics.setColor(1, 1, 1, 1)
		quadSlice.draw(slice3, mx - 64, my - 64, demo_w, demo_h, true)

		love.graphics.pop()

		love.graphics.push("all")

		label(8, 424, "mirrored tile tests (normal; horizontal; vertical; horizontal+vertical)")

		demo_w = math.floor(96 + math.cos(demo_time + math.pi/4) * 32)
		demo_h = math.floor(96 + math.sin((demo_time / 1.1) + math.pi/4) * 32)

		quadSlice.draw(slice_mir_none, 8 + 196*0, 448, demo_w, demo_h)
		quadSlice.draw(slice_mir_h, 8 + 196*1, 448, demo_w, demo_h)
		quadSlice.draw(slice_mir_v, 8 + 196*2, 448, demo_w, demo_h)
		quadSlice.draw(slice_mir_hv, 8 + 196*3, 448, demo_w, demo_h)

		love.graphics.pop()

	-- Spritebatch tests.
	else
		demo_w = math.floor(96 + math.cos(demo_time + math.pi/4) * 32)
		demo_h = math.floor(96 + math.sin((demo_time / 1.1) + math.pi/4) * 32)

		batch1:clear()
		quadSlice.batchAdd(batch1, slice_mir_none, 0, 0, demo_w, demo_h, false)
		
		label(mx, my - 24, "batch:clear(); batch:add()")
		love.graphics.draw(batch1, mx, my)

		batch1:clear()
		quadSlice.batchAdd(batch1, slice_mir_none, 0, 160, demo_w, demo_h, true)
		label(mx, my - 24 + 160, "^ hollow == true")
		love.graphics.draw(batch1, mx, my)

		label(400, 2, "batch:set() -- hollow == false")
		quadSlice.batchSet(batch2, 1, slice_mir_none, 0, 0, demo_w, demo_h, false)
		love.graphics.draw(batch2, 400, 16)

		label(400, 384, "batch:set() -- hollow == true")
		quadSlice.batchSet(batch3, 1, slice_mir_none, 0, 0, demo_w, demo_h, true)
		love.graphics.draw(batch3, 400, 400)
	end

	love.graphics.print("PAGE " .. page .. "/2 (1: lg.draw tests, 2: spritebatch tests)", 8, love.graphics.getHeight() - love.graphics.getFont():getHeight())
end
