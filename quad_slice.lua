--[[
	A basic 9-slice drawing library for LÖVE, intended for 2D UI / menu elements.
	See README.md for usage notes.

	Version: 0.0.2 (Beta)

	License: MIT

	Copyright (c) 2022 RBTS

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
--]]


--[[
9slice quad layout:

   x    w1   w2   w3
y  +----+----+----+
   |q1  |q2  |q3  |
h1 +----+----+----+
   |q4  |q5  |q6  |
h2 +----+----+----+
   |q7  |q8  |q9  |
h3 +----+----+----+

Quad positions and dimensions may not match the info stored in the 9slice table due to support
for mirrored layouts:

	H-mirrored 9slices:
	* Quads 3, 6 and 9 are reversed versions of 1, 4 and 7, with negative widths.

	V-mirrored 9slices:
	* Quads 7, 8 and 9 are reversed versions of 1, 2 and 3, with negative heights.

	HV-mirrored 9slices:
	* Quads 3 and 6 are h-flipped versions of 1 and 4
	* Quads 7 and 8 are v-flipped versions of 1 and 2
	* Quad 9 is an h-flipped and v-flipped version of 1
--]]


local quadSlice = {}


-- * Internal *


local function errGTZero(arg_n)
	error("argument #" .. arg_n .. " must be greater than zero.", 2)
end


local function new9Slice(image, x, y, w1, h1, w2,h2, w3,h3)

	local slice = {}

	slice.image = image

	slice.x = x
	slice.y = y

	slice.w = w1 + w2 + w3
	slice.h = h1 + h2 + h3

	slice.w1, slice.h1 = w1, h1
	slice.w2, slice.h2 = w2, h2
	slice.w3, slice.h3 = w3, h3

	local image_w, image_h = image:getDimensions()
	local newQuad = love.graphics.newQuad
	local quads = {}

	quads[1] = newQuad(x, y, w1, h1, image_w, image_h)
	quads[2] = newQuad(x + w1, y, w2, h1, image_w, image_h)
	quads[3] = newQuad(x + w1 + w2, y, w3, h1, image_w, image_h)

	quads[4] = newQuad(x, y + h1, w1, h2, image_w, image_h)
	quads[5] = newQuad(x + w1, y + h1, w2, h2, image_w, image_h)
	quads[6] = newQuad(x + w1 + w2, y + h1, w3, h2, image_w, image_h)

	quads[7] = newQuad(x, y + h1 + h2, w1, h3, image_w, image_h)
	quads[8] = newQuad(x + w1, y + h1 + h2, w2, h3, image_w, image_h)
	quads[9] = newQuad(x + w1 + w2, y + h1 + h2, w3, h3, image_w, image_h)

	slice.quads = quads

	return slice
end


-- Overwrites quad 'dst' with flipped and/or mirrored viewport coordinates from quad 'src'. The reference image
-- must have the 'mirroredrepeat' WrapMode assigned to the desired axes. Both quads are assumed to reference
-- the same texture, and 'src' is expected to have coordinates >= 0 and positive width and height.
local function mirrorQuad(src, dst, mirror_h, mirror_v)

	local x, y, w, h = src:getViewport()

	if mirror_h then
		x = -(x + w)
	end
	if mirror_v then
		y = -(y + h)
	end

	dst:setViewport(x, y, w, h)
end


-- * / Internal *


-- * Slice table creation *


function quadSlice.new9Slice(image, x,y, w1,h1, w2,h2, w3,h3)

	-- Assertions
	-- [[
	if w1 <= 0 then errGTZero(4)
	elseif h1 <= 0 then errGTZero(5)
	elseif w2 <= 0 then errGTZero(6)
	elseif h2 <= 0 then errGTZero(7)
	elseif w3 <= 0 then errGTZero(8)
	elseif h3 <= 0 then errGTZero(9) end
	--]]

	local slice = new9Slice(image, x,y, w1,h1, w2,h2, w3,h3)

	return slice
end


function quadSlice.new9SliceMirrorH(image, x,y, w1,h1, w2,h2, h3)

	-- Assertions
	-- [[
	if w1 <= 0 then errGTZero(4)
	elseif h1 <= 0 then errGTZero(5)
	elseif w2 <= 0 then errGTZero(6)
	elseif h2 <= 0 then errGTZero(7)
	elseif h3 <= 0 then errGTZero(8) end
	--]]

	local w3 = w1
	local slice = new9Slice(image, x,y, w1,h1, w2,h2, w3,h3)
	local quads = slice.quads

	mirrorQuad(quads[1], quads[3], true, false)
	mirrorQuad(quads[4], quads[6], true, false)
	mirrorQuad(quads[7], quads[9], true, false)

	return slice
end


function quadSlice.new9SliceMirrorV(image, x,y, w1,h1, w2,h2, w3)

	-- Assertions
	-- [[
	if w1 <= 0 then errGTZero(4)
	elseif h1 <= 0 then errGTZero(5)
	elseif w2 <= 0 then errGTZero(6)
	elseif h2 <= 0 then errGTZero(7)
	elseif w3 <= 0 then errGTZero(8) end
	--]]

	local h3 = h1
	local slice = new9Slice(image, x,y, w1,h1, w2,h2, w3,h3)
	local quads = slice.quads

	mirrorQuad(quads[1], quads[7], false, true)
	mirrorQuad(quads[2], quads[8], false, true)
	mirrorQuad(quads[3], quads[9], false, true)

	return slice
end


function quadSlice.new9SliceMirrorHV(image, x,y, w1,h1, w2,h2)

	-- Assertions
	-- [[
	if w1 <= 0 then errGTZero(4)
	elseif h1 <= 0 then errGTZero(5)
	elseif w2 <= 0 then errGTZero(6)
	elseif h2 <= 0 then errGTZero(7) end
	--]]

	local w3, h3 = w1, h1
	local slice = new9Slice(image, x,y, w1,h1, w2,h2, w3,h3)
	local quads = slice.quads

	mirrorQuad(quads[1], quads[3], true, false)
	mirrorQuad(quads[4], quads[6], true, false)

	mirrorQuad(quads[1], quads[7], false, true)
	mirrorQuad(quads[2], quads[8], false, true)

	mirrorQuad(quads[1], quads[9], true, true)

	return slice
end


-- * / Slice table creation *


-- * Slice positioning and drawing *


function quadSlice.getDrawParams(slice, w, h)

	if w <= 0 or h <= 0 then return end

	local w1, h1 = slice.w1, slice.h1
	local w3, h3 = slice.w3, slice.h3
	local w2, h2 = math.max(0, w - (w1 + w3)), math.max(0, h - (h1 + h3))

	-- This code block allows the edge quads to be crunched down if there isn't enough room to render everything.
	-- It looks pretty ugly, and should be avoided when possible.
	-- [[
	w1 = math.min(w1, w1 * (w / (slice.w1 + slice.w3)))
	w3 = math.min(w3, w3 * (w / (slice.w1 + slice.w3)))

	h1 = math.min(h1, h1 * (h / (slice.h1 + slice.h3)))
	h3 = math.min(h3, h3 * (h / (slice.h1 + slice.h3)))
	--]]

	local sw1 = w1 / slice.w1
	local sh1 = h1 / slice.h1

	local sw2 = w2 / slice.w2
	local sh2 = h2 / slice.h2

	local sw3 = w3 / slice.w3
	local sh3 = h3 / slice.h3

	return w1, h1, w2, h2, w3, h3, sw1, sh1, sw2, sh2, sw3, sh3
end


function quadSlice.draw(slice, x, y, w, h, hollow)

	if w <= 0 or h <= 0 then return end

	local w1, h1, w2, h2, w3, h3, sw1, sh1, sw2, sh2, sw3, sh3 = quadSlice.getDrawParams(slice, w, h)
	quadSlice.drawFromParams(slice, x, y, w1, h1, w2, h2, w3, h3, sw1, sh1, sw2, sh2, sw3, sh3, hollow)
end


function quadSlice.drawFromParams(slice, x, y, w1, h1, w2, h2, w3, h3, sw1, sh1, sw2, sh2, sw3, sh3, hollow)

	local quads = slice.quads
	local image = slice.image

	-- Top row
	love.graphics.draw(image, quads[1], x, y, 0, sw1, sh1)
	love.graphics.draw(image, quads[2], x + w1, y, 0, sw2, sh1)
	love.graphics.draw(image, quads[3], x + w1 + w2, y, 0, sw3, sh1)

	-- Middle row
	love.graphics.draw(image, quads[4], x, y + h1, 0, sw1, sh2)

	if not hollow then
		love.graphics.draw(image, quads[5], x + w1, y + h1, 0, sw2, sh2)
	end

	love.graphics.draw(image, quads[6], x + w1 + w2, y + h1, 0, sw3, sh2)

	-- Bottom row
	love.graphics.draw(image, quads[7], x, y + h1 + h2, 0, sw1, sh3)
	love.graphics.draw(image, quads[8], x + w1, y + h1 + h2, 0, sw2, sh3)
	love.graphics.draw(image, quads[9], x + w1 + w2, y + h1 + h2, 0, sw3, sh3)
end


function quadSlice.batchAdd(batch, slice, x, y, w, h, hollow)

	if w <= 0 or h <= 0 then return end

	local w1, h1, w2, h2, w3, h3, sw1, sh1, sw2, sh2, sw3, sh3 = quadSlice.getDrawParams(slice, w, h)
	local last_index = quadSlice.batchAddFromParams(batch, slice, x, y, w1, h1, w2, h2, w3, h3, sw1, sh1, sw2, sh2, sw3, sh3, hollow)

	return last_index
end


function quadSlice.batchAddFromParams(batch, slice, x, y, w1, h1, w2, h2, w3, h3, sw1, sh1, sw2, sh2, sw3, sh3, hollow)

	local quads = slice.quads
	local image = slice.image

	-- Top row
	batch:add(quads[1], x, y, 0, sw1, sh1)
	batch:add(quads[2], x + w1, y, 0, sw2, sh1)
	batch:add(quads[3], x + w1 + w2, y, 0, sw3, sh1)

	-- Middle row
	batch:add(quads[4], x, y + h1, 0, sw1, sh2)

	if not hollow then
		batch:add(quads[5], x + w1, y + h1, 0, sw2, sh2)
	end

	batch:add(quads[6], x + w1 + w2, y + h1, 0, sw3, sh2)

	-- Bottom row
	batch:add(quads[7], x, y + h1 + h2, 0, sw1, sh3)
	batch:add(quads[8], x + w1, y + h1 + h2, 0, sw2, sh3)
	local last_index = batch:add(quads[9], x + w1 + w2, y + h1 + h2, 0, sw3, sh3)

	return last_index
end


function quadSlice.batchSet(batch, index, slice, x, y, w, h, hollow)

	if w <= 0 or h <= 0 then return end

	local w1, h1, w2, h2, w3, h3, sw1, sh1, sw2, sh2, sw3, sh3 = quadSlice.getDrawParams(slice, w, h)
	quadSlice.batchSetFromParams(batch, index, slice, x, y, w1, h1, w2, h2, w3, h3, sw1, sh1, sw2, sh2, sw3, sh3, hollow)
end


function quadSlice.batchSetFromParams(batch, index, slice, x, y, w1, h1, w2, h2, w3, h3, sw1, sh1, sw2, sh2, sw3, sh3, hollow)

	local quads = slice.quads
	local image = slice.image

	-- Top row
	batch:set(index, quads[1], x, y, 0, sw1, sh1)
	batch:set(index + 1, quads[2], x + w1, y, 0, sw2, sh1)
	batch:set(index + 2, quads[3], x + w1 + w2, y, 0, sw3, sh1)

	-- Middle row
	batch:set(index + 3, quads[4], x, y + h1, 0, sw1, sh2)

	if not hollow then
		batch:set(index + 4, quads[5], x + w1, y + h1, 0, sw2, sh2)
		index = index + 1
	end

	batch:set(index + 4, quads[6], x + w1 + w2, y + h1, 0, sw3, sh2)

	-- Bottom row
	batch:set(index + 5, quads[7], x, y + h1 + h2, 0, sw1, sh3)
	batch:set(index + 6, quads[8], x + w1, y + h1 + h2, 0, sw2, sh3)
	batch:set(index + 7, quads[9], x + w1 + w2, y + h1 + h2, 0, sw3, sh3)
end


-- * / Slice positioning and drawing *


return quadSlice
