-- QuadSlice Test/Demo.


--love.window.setVSync(0)
love.keyboard.setKeyRepeat(true)

local quadSlice = require("quad_slice")
quadSlice.populateAlternativeDrawFunctions(true)


local image1 = love.graphics.newImage("demo_res/9s_test1.png")
image1:setFilter("nearest", "nearest")
local slice1 = quadSlice.newSlice(8,8, 3,3, 2,2, 3,3, image1:getDimensions())

local image2 = love.graphics.newImage("demo_res/9s_test2.png")
image2:setFilter("linear", "linear")
local slice2 = quadSlice.newSlice(8,8, 3,3, 2,2, 3,3, image2:getDimensions())

local image3 = love.graphics.newImage("demo_res/9s_test3.png")
image3:setFilter("nearest", "nearest")
local slice3 = quadSlice.newSlice(0,0, 32,32, 8,8, 32,32, image3:getDimensions())
slice3:setTileEnabled(5, false) -- hide center tile

local image_mir = love.graphics.newImage("demo_res/9s_mir.png")
image_mir:setFilter("nearest", "nearest")
image_mir:setWrap("mirroredrepeat", "mirroredrepeat") -- <- Important

local image_par = love.graphics.newImage("demo_res/9s_partial.png")

local slice_mir_none = quadSlice.newSlice(0,0, 32,32, 32,32, 32,32, image_mir:getDimensions())

local slice_mir_h = quadSlice.newSlice(0,0, 32,32, 32,32, 32,32, image_mir:getDimensions())
slice_mir_h:setMirroring(true, false)

local slice_mir_v = quadSlice.newSlice(0,0, 32,32, 32,32, 32,32, image_mir:getDimensions())
slice_mir_v:setMirroring(false, true)

local slice_mir_hv = quadSlice.newSlice(0,0, 32,32, 32,32, 32,32, image_mir:getDimensions())
slice_mir_hv:setMirroring(true, true)

-- 1.2.1: Test unmirroring
--[[
do
	local t = true
	slice_mir_h:setMirroring()
	slice_mir_v:setMirroring()
	slice_mir_hv:setMirroring()
end
--]]


local batch1 = love.graphics.newSpriteBatch(image_mir) -- tests batch:add()
local batch2 = love.graphics.newSpriteBatch(image_mir)
local batch3 = love.graphics.newSpriteBatch(image_mir)


local page = 1
local n_pages = 5


-- Page 3 setup
local p3_start = 1
local partial_slices = {}
-- Make Slices with every combination of zero-sized columns and rows.
for w1 = 0, 1 do
	for w2 = 0, 1 do
		for w3 = 0, 1 do
			for h1 = 0, 1 do
				for h2 = 0, 1 do
					for h3 = 0, 1 do
						table.insert(partial_slices,
							quadSlice.newSlice(
								0,0,
								w1*32,h1*32,
								w2*32,h2*32,
								w3*32,h3*32,
								image_par:getDimensions()
							)
						)
					end
				end
			end
		end
	end
end


-- Page 4 setup
local slice_enable = quadSlice.newSlice(0,0, 32,32, 32,32, 32,32, image_mir:getDimensions())
local p4_timer = 0
local p4_timer_max = 0.25
local p4_tick = 0


-- Page 5 setup
local p5_d_index = 0
local p5_key_held = 0


function love.keypressed(kc, sc, rep)
	local num = tonumber(sc)

	if sc == "escape" then
		love.event.quit()
		return

	-- Page selection.
	elseif num and num >= 1 and num <= n_pages then
		page = num

	-- Toggle VSync.
	elseif sc == "0" then
		love.window.setVSync(love.window.getVSync() ~= 0 and 0 or 1)
	end

	-- Step through page 3 partial slices
	if page == 3 then
		if sc == "left" then
			p3_start = math.max(1, p3_start - 1)

		elseif sc == "right" then
			p3_start = math.min(#partial_slices, p3_start + 1)
		end

	-- Page 5: change the alternative draw function index
	elseif page == 5 then
		if kc == "left" or kc == "right" then
			if rep then
				p5_key_held = p5_key_held + 1
			end
		end

		if kc == "left" then
			p5_d_index = math.max(0, p5_d_index - (1 + p5_key_held))

		elseif kc == "right" then
			p5_d_index = math.min(511, p5_d_index + (1 + p5_key_held))
		end
	end
end


function love.keyreleased(kc, sc)
	if page == 5 then
		if kc == "left" or kc == "right" then
			p5_key_held = 0
		end
	end
end


function love.update(dt)
	if page == 4 then
		p4_timer = p4_timer + dt
	end
end


-- Helper for printing text to the display.
local function label(x, y, text)
	love.graphics.push("all")

	love.graphics.origin()
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.print(text, x, y)

	love.graphics.pop()
end


local function _dec2BinStr(n) -- quick-and-dumb string maker for binary numbers < 512.
	n = math.floor(n)
	local s = ""
	for i = 1, 9 do
		s = tostring(n % 2) .. s
		n = math.floor(n / 2)
	end
	return "0b" .. s
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
		slice1:draw(image1, 8, 8, demo_w, demo_h)

		love.graphics.pop()

		love.graphics.push("all")

		label(384, 0, "bilinear")

		demo_w = math.floor(128*2 + math.cos(demo_time) * 64)
		demo_h = math.floor(128*2 + math.sin(demo_time / 1.1) * 64)

		slice2:draw(image2, 384, 24, demo_w, demo_h)

		love.graphics.pop()

		love.graphics.push("all")

		label(mx - 24, my - 24, "hollow center tile")

		demo_w = math.floor(128*2 + math.cos(demo_time + math.pi/4) * 64)
		demo_h = math.floor(128*2 + math.sin((demo_time / 1.1) + math.pi/4) * 64)

		love.graphics.setColor(0, 0, 1, 0.5)

		love.graphics.setColor(1, 1, 1, 1)
		slice3:draw(image3, mx - 64, my - 64, demo_w, demo_h)


		love.graphics.pop()

		love.graphics.push("all")

		label(8, 400, "mirrored tile tests")
		label(8 + 196*0, 424, "normal")
		label(8 + 196*1, 424, "horizontal")
		label(8 + 196*2, 424, "vertical")
		label(8 + 196*3, 424, "horizontal+vertical")

		demo_w = math.floor(96 + math.cos(demo_time + math.pi/4) * 32)
		demo_h = math.floor(96 + math.sin((demo_time / 1.1) + math.pi/4) * 32)

		slice_mir_none:draw(image_mir, 8 + 196*0, 448, demo_w, demo_h)
		slice_mir_h:draw(image_mir, 8 + 196*1, 448, demo_w, demo_h)
		slice_mir_v:draw(image_mir, 8 + 196*2, 448, demo_w, demo_h)
		slice_mir_hv:draw(image_mir, 8 + 196*3, 448, demo_w, demo_h)

		love.graphics.pop()

	-- Spritebatch tests.
	elseif page == 2 then
		demo_w = math.floor(96 + math.cos(demo_time + math.pi/4) * 32)
		demo_h = math.floor(96 + math.sin((demo_time / 1.1) + math.pi/4) * 32)

		batch1:clear()
		slice_mir_none:batchAdd(batch1, 0, 0, demo_w, demo_h)

		label(mx, my - 24, "batch:clear(); batch:add()")
		love.graphics.draw(batch1, mx, my)

	-- Zero-column, zero-row tests
	elseif page == 3 then
		love.graphics.printf("Press left/right to scroll.", 0, 4, love.graphics.getWidth(), "center")
		love.graphics.translate(0, 32)
		demo_w = math.floor(96 + math.cos(demo_time + math.pi/4) * 32)
		demo_h = math.floor(96 + math.sin((demo_time / 1.1) + math.pi/4) * 32)

		local xx, yy = 0, 0
		local y_dash = math.floor(love.graphics.getFont():getHeight() * 2.5)
		local x_add, y_add = 48, 96
		for i = p3_start, #partial_slices do
			local slice = partial_slices[i]
			slice:draw(image_par, xx, yy + y_dash, demo_w, demo_h)
			love.graphics.print(
				"w1: " .. slice.w1 ..
				", w2: " .. slice.w2 ..
				", w3: " .. slice.w3 ..
				"\nh1: " .. slice.h1 ..
				", h2: " .. slice.h2 ..
				", h3: " .. slice.h3,
				xx, yy
			)
			xx = xx + x_add + math.floor(image_par:getWidth())
			if xx > love.graphics.getWidth() then
				xx = 0
				yy = yy + y_add + math.floor(image_par:getHeight())
			end
			if yy > love.graphics.getHeight() then
				break
			end
		end

		love.graphics.origin()

	-- Enabling and disabling individual tiles.
	elseif page == 4 then
		local draw_w, draw_h = 160, 160
		local mid_x = math.floor((love.graphics.getWidth() - draw_w) / 2)
		local mid_y = math.floor((love.graphics.getHeight() - draw_h) / 2)

		-- First, draw a dim version of the slice with all tiles enabled so that it isn't so jarring.
		love.graphics.setColor(1, 1, 1, 0.34)
		slice_enable:resetTiles()
		slice_enable:draw(image_mir, mid_x, mid_y, draw_w, draw_h)
		love.graphics.setColor(1, 1, 1, 1)

		-- Set each tile based on elapsed time.
		slice_enable:setTileEnabled(1, p4_tick % 2 == 1)
		slice_enable:setTileEnabled(2, math.floor(p4_tick /   2) % 2 == 1)
		slice_enable:setTileEnabled(3, math.floor(p4_tick /   4) % 2 == 1)
		slice_enable:setTileEnabled(4, math.floor(p4_tick /   8) % 2 == 1)
		slice_enable:setTileEnabled(5, math.floor(p4_tick /  16) % 2 == 1)
		slice_enable:setTileEnabled(6, math.floor(p4_tick /  32) % 2 == 1)
		slice_enable:setTileEnabled(7, math.floor(p4_tick /  64) % 2 == 1)
		slice_enable:setTileEnabled(8, math.floor(p4_tick / 128) % 2 == 1)
		slice_enable:setTileEnabled(9, math.floor(p4_tick / 256) % 2 == 1)

		slice_enable:draw(image_mir, mid_x, mid_y, draw_w, draw_h)

		-- (p4_timer is incremented in love.update().)
		if p4_timer >= p4_timer_max then
			p4_timer = p4_timer - p4_timer_max
			p4_tick = p4_tick + 1
			p4_tick = p4_tick % 512
		end

	-- Test alternative draw functions
	elseif page == 5 then
		if type(quadSlice.draw_functions) ~= "table" then
			love.graphics.print("[!] quadSlice.draw_functions is not initialized.")
		else
			local str = "Press left/right to select a draw function\nIndex: [" .. p5_d_index .. "] | [" .. _dec2BinStr(p5_d_index) .. "]"
			love.graphics.printf(str, 0, 4, love.graphics.getWidth(), "center")

			-- For demo purposes, we will change the slice's draw function. The slice is shared
			-- with other test pages, so we need to change it back after drawing.
			local old_draw_fn = slice_enable.drawFromParams

			local draw_w, draw_h = 160, 160
			local mid_x = math.floor((love.graphics.getWidth() - draw_w) / 2)
			local mid_y = math.floor((love.graphics.getHeight() - draw_h) / 2)

			love.graphics.setColor(1, 1, 1, 0.34)
			slice_enable.drawFromParams = nil
			slice_enable:resetTiles()
			slice_enable:draw(image_mir, mid_x, mid_y, draw_w, draw_h)
			love.graphics.setColor(1, 1, 1, 1)

			local draw_fn_tbl = quadSlice.draw_functions[p5_d_index]

			if draw_fn_tbl then
				slice_enable.drawFromParams = draw_fn_tbl
			end

			-- Uncomment to run a simple stress test.
			--[[
			love.graphics.setColor(1,1,1,0.1)
			for i = 1, 1000 do
				slice_enable:draw(
					image_mir,
					math.floor(0.5 + mid_x + math.cos(demo_time) * i/4),
					math.floor(0.5 + mid_y + math.sin(demo_time) * i/5),
					draw_w,
					draw_h
				)
			end
			--]]

			slice_enable:draw(image_mir, mid_x, mid_y, draw_w, draw_h)

			love.graphics.setColor(1, 1, 1, 1)
			slice_enable.drawFromParams = old_draw_fn
		end
	end

	local bottom_dash_y_margin = 6
	local bottom_text_h = love.graphics.getFont():getHeight()
	local bottom_dash_y = love.graphics.getHeight() - bottom_text_h
	love.graphics.setColor(0, 0, 0, 0.8)
	love.graphics.rectangle(
		"fill",
		0, bottom_dash_y - bottom_dash_y_margin,
		love.graphics.getWidth(), bottom_text_h + bottom_dash_y_margin
	)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.print(
		"PAGE " .. page .. "/" .. n_pages .. "\t(1: lg.draw, 2: spritebatch, 3: zero column/row, 4: tile enable, 5: alt draw)" ..
		"\t0: VSync (" .. tostring(love.window.getVSync()) .. ")",
		8,
		bottom_dash_y
	)
	love.graphics.print("FPS: " .. love.timer.getFPS(), love.graphics.getWidth() - 72, bottom_dash_y)
end
