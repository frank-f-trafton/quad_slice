--[[
	QuadSlice: a basic 9-slice library for LÖVE, intended for 2D UI / menu elements.
	See README.md for usage notes.

	Version: 1.1.0

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


local function errGTZero(id, arg_n, level)
	error("argument #" .. arg_n .. " (" .. id .. ") must be a number greater than zero.", level or 2)
end


local function errBadType(id, arg_n, val, expected, level)
	error("argument #" .. arg_n .. " (" .. id .. "): bad type (expected " .. expected .. ", got " .. type(val) .. ").", level or 2)
end


local function assertDrawParams(arg_n_start, quads, hollow, x,y, w1,h1, w2,h2, w3,h3, sw1,sh1, sw2,sh2, sw3,sh3)

	if type(quads) ~= "table" then errBadType("quads", arg_n_start + 0, quads, "table", 3)
	elseif hollow ~= nil and type(hollow) ~= "boolean" then errBadType("hollow", arg_n_start + 1, hollow, "bool/nil", 3)
	elseif type(x) ~= "number" then errBadType("x", arg_n_start + 2, x, "number", 3)
	elseif type(y) ~= "number" then errBadType("y", arg_n_start + 3, y, "number", 3)
	elseif type(w1) ~= "number" then errBadType("w1", arg_n_start + 4, w1, "number", 3)
	elseif type(h1) ~= "number" then errBadType("h1", arg_n_start + 5, h1, "number", 3)
	elseif type(w2) ~= "number" then errBadType("w2", arg_n_start + 6, w2, "number", 3)
	elseif type(h2) ~= "number" then errBadType("h2", arg_n_start + 7, h2, "number", 3)
	elseif type(w3) ~= "number" then errBadType("w3", arg_n_start + 8, w3, "number", 3)
	elseif type(h3) ~= "number" then errBadType("h3", arg_n_start + 9, h3, "number", 3)
	elseif type(sw1) ~= "number" then errBadType("sw1", arg_n_start + 10, sw1, "number", 3)
	elseif type(sh1) ~= "number" then errBadType("sh1", arg_n_start + 11, sh1, "number", 3)
	elseif type(sw2) ~= "number" then errBadType("sw2", arg_n_start + 12, sw2, "number", 3)
	elseif type(sh2) ~= "number" then errBadType("sh2", arg_n_start + 13, sh2, "number", 3)
	elseif type(sw3) ~= "number" then errBadType("sw3", arg_n_start + 14, sw3, "number", 3)
	elseif type(sh3) ~= "number" then errBadType("sh3", arg_n_start + 15, sh3, "number", 3) end
end


local function assertDraw(arg_n_start, slice, x, y, w, h, hollow)

	if type(slice) ~= "table" then errBadType("slice", arg_n_start + 0, slice, "table")
	elseif type(x) ~= "number" then errBadType("x", arg_n_start + 1, x, "number", 3)
	elseif type(y) ~= "number" then errBadType("y", arg_n_start + 2, y, "number", 3)
	elseif type(w) ~= "number" then errBadType("w", arg_n_start + 3, w, "number", 3)
	elseif type(h) ~= "number" then errBadType("h", arg_n_start + 4, h, "number", 3)
	elseif hollow ~= nil and type(hollow) ~= "boolean" then errBadType("hollow", arg_n_start + 5, hollow, "bool/nil") end
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


function quadSlice.new9Slice(x,y, w1,h1, w2,h2, w3,h3, iw,ih)

	-- Assertions
	-- [[
	if type(x) ~= "number" then errBadType("x", 1, x, "number", 3)
	elseif type(y) ~= "number" then errBadType("y", 2, y, "number", 3)
	elseif type(w1) ~= "number" or w1 <= 0 then errGTZero("w1", 3, 3)
	elseif type(h1) ~= "number" or h1 <= 0 then errGTZero("h1", 4, 3)
	elseif type(w2) ~= "number" or w2 <= 0 then errGTZero("w2", 5, 3)
	elseif type(h2) ~= "number" or h2 <= 0 then errGTZero("h2", 6, 3)
	elseif type(w3) ~= "number" or w3 <= 0 then errGTZero("w3", 7, 3)
	elseif type(h3) ~= "number" or h3 <= 0 then errGTZero("h3", 8, 3)
	elseif type(iw) ~= "number" or iw <= 0 then errGTZero("iw", 9, 3)
	elseif type(ih) ~= "number" or ih <= 0 then errGTZero("ih", 10, 3) end
	--]]

	local slice = {}

	slice.iw, slice.ih = iw, ih
	slice.x, slice.y = x, y

	slice.w, slice.h = (w1 + w2 + w3), (h1 + h2 + h3)

	slice.w1, slice.h1 = w1, h1
	slice.w2, slice.h2 = w2, h2
	slice.w3, slice.h3 = w3, h3

	local newQuad = love.graphics.newQuad

	-- You could comment out or delete this if you intend to only use the mesh helper functions.
	-- [[
	local quads = {}

	quads[1] = newQuad(x, y, w1, h1, iw, ih)
	quads[2] = newQuad(x + w1, y, w2, h1, iw, ih)
	quads[3] = newQuad(x + w1 + w2, y, w3, h1, iw, ih)

	quads[4] = newQuad(x, y + h1, w1, h2, iw, ih)
	quads[5] = newQuad(x + w1, y + h1, w2, h2, iw, ih)
	quads[6] = newQuad(x + w1 + w2, y + h1, w3, h2, iw, ih)

	quads[7] = newQuad(x, y + h1 + h2, w1, h3, iw, ih)
	quads[8] = newQuad(x + w1, y + h1 + h2, w2, h3, iw, ih)
	quads[9] = newQuad(x + w1 + w2, y + h1 + h2, w3, h3, iw, ih)

	slice.quads = quads
	--]]

	return slice
end


-- * / Slice table creation *


-- * Slice positioning and drawing *


function quadSlice.setQuadMirroring(slice, hori, vert)

	-- Assertions
	-- [[
	if type(slice) ~= "table" then errBadType("slice", 1, slice, "table")
	elseif hori ~= nil and type(hori) ~= "boolean" then errBadType("hori", 2, hori, "bool/nil")
	elseif vert ~= nil and type(vert) ~= "boolean" then errBadType("vert", 3, vert, "bool/nil") end
	--]]

	-- NOTE: this has no effect on the mesh helper functions, as they don't use LÖVE quads.

	local quads = slice.quads
	local x,y, w1,h1, w2,h2, w3,h3 = slice.x, slice.y, slice.w1, slice.h1, slice.w2, slice.h2, slice.w3, slice.h3

	-- First, reset all mirror-able quads so that this action is easy to undo.
	quads[3]:setViewport(x, y + h1, w1, h2)
	quads[6]:setViewport(x + w1, y + h1, w2, h2)
	quads[7]:setViewport(x, y + h1 + h2, w1, h3)
	quads[8]:setViewport(x + w1, y + h1 + h2, w2, h3)	
	quads[9]:setViewport(x + w1 + w2, y + h1, w3, h2)

	if hori and vert then
		mirrorQuad(quads[1], quads[3], true, false)
		mirrorQuad(quads[4], quads[6], true, false)

		mirrorQuad(quads[1], quads[7], false, true)
		mirrorQuad(quads[2], quads[8], false, true)

		mirrorQuad(quads[1], quads[9], true, true)

	elseif hori then
		mirrorQuad(quads[1], quads[3], true, false)
		mirrorQuad(quads[4], quads[6], true, false)
		mirrorQuad(quads[7], quads[9], true, false)

	elseif vert then
		mirrorQuad(quads[1], quads[7], false, true)
		mirrorQuad(quads[2], quads[8], false, true)
		mirrorQuad(quads[3], quads[9], false, true)		
	end
end


function quadSlice.getDrawParams(slice, w, h)

	-- Assertions -- commented out by default.
	--[[
	if type(slice) ~= "table" then errBadType("slice", 1, slice, "table")
	elseif type(w) ~= "number" then errBadType("w", 2, w, "number")
	elseif type(h) ~= "number" then errBadType("h", 3, h, "number") end
	--]]

	if w <= 0 or h <= 0 then
		return
	end

	local w1, h1 = slice.w1, slice.h1
	local w3, h3 = slice.w3, slice.h3
	local w2, h2 = math.max(0, w - (w1 + w3)), math.max(0, h - (h1 + h3))

	-- Allows edges to be crunched down.
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

	return w1,h1, w2,h2, w3,h3, sw1,sh1, sw2,sh2, sw3,sh3
end


function quadSlice.draw(image, slice, x, y, w, h, hollow)

	-- Assertions -- commented out by default.
	--[[
	assertDraw(2, slice, x, y, w, h, hollow)
	--]]

	if w <= 0 or h <= 0 then
		return
	end

	quadSlice.drawFromParams(image, slice.quads, hollow, x,y, quadSlice.getDrawParams(slice, w, h))
end


function quadSlice.drawFromParams(image, quads, hollow, x,y, w1,h1, w2,h2, w3,h3, sw1,sh1, sw2,sh2, sw3,sh3)

	-- Assertions -- commented out by default.
	--[[
	assertDrawParams(2, quads, hollow, x,y, w1,h1, w2,h2, w3,h3, sw1,sh1, sw2,sh2, sw3,sh3)
	--]]

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

	-- Assertions -- commented out by default.
	--[[
	assertDraw(2, slice, x, y, w, h, hollow)
	--]]

	if w <= 0 or h <= 0 then
		return
	end

	local last_index = quadSlice.batchAddFromParams(batch, slice.quads, hollow, x, y, quadSlice.getDrawParams(slice, w, h))

	return last_index
end


function quadSlice.batchAddFromParams(batch, quads, hollow, x,y, w1,h1, w2,h2, w3,h3, sw1,sh1, sw2,sh2, sw3,sh3)

	-- Assertions -- commented out by default.
	--[[
	assertDrawParams(2, quads, hollow, x,y, w1,h1, w2,h2, w3,h3, sw1,sh1, sw2,sh2, sw3,sh3)
	--]]

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

	-- Assertions -- commented out by default.
	--[[
	assertDraw(3, slice, x, y, w, h, hollow)
	--]]

	if w <= 0 or h <= 0 then
		return
	end

	quadSlice.batchSetFromParams(batch, index, slice.quads, hollow, x, y, quadSlice.getDrawParams(slice, w, h))
end


function quadSlice.batchSetFromParams(batch, index, quads, hollow, x,y, w1,h1, w2,h2, w3,h3, sw1,sh1, sw2,sh2, sw3,sh3)

	-- Assertions -- commented out by default.
	--[[
	if type(index) ~= "number" then errBadType("index", 2, index, "number") end
	assertDrawParams(3, quads, hollow, x,y, w1,h1, w2,h2, w3,h3, sw1,sh1, sw2,sh2, sw3,sh3)
	--]]

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


-- * Mesh helpers *


--[[
	Actual drawing of the mesh is left to the library user, as there are so many ways to approach it.
	See 'test_mesh_render.lua' for a basic example.
--]]


function quadSlice.getTextureUV(slice)

	-- No assertions.

	local iw, ih = slice.iw, slice.ih

	local sx1 = slice.x / iw
	local sy1 = slice.y / ih
	local sx2 = (slice.x + slice.w1) / iw
	local sy2 = (slice.y + slice.h1) / ih
	local sx3 = (slice.x + slice.w1 + slice.w2) / iw
	local sy3 = (slice.y + slice.h1 + slice.h2) / ih
	local sx4 = (slice.x + slice.w1 + slice.w2 + slice.w3) / iw
	local sy4 = (slice.y + slice.h1 + slice.h2 + slice.h3) / ih

	return sx1, sy1, sx2, sy2, sx3, sy3, sx4, sy4
end


function quadSlice.getStretchedVertices(slice, w, h)

	-- No assertions.

	-- Crunch down edges
	-- [[
	local crunch_w = math.min(1, w / slice.w)
	local crunch_h = math.min(1, h / slice.h)
	local w1 = math.floor(slice.w1 * crunch_w)
	local h1 = math.floor(slice.h1 * crunch_h)
	local w3 = math.floor(slice.w3 * crunch_w)
	local h3 = math.floor(slice.h3 * crunch_h)
	--]]

	-- Preserve edges
	--[[
	w = math.max(w, slice.w)
	h = math.max(h, slice.h)
	local w1 = slice.w1
	local h1 = slice.h1
	local w3 = slice.w3
	local h3 = slice.h3
	--]]

	local x2 = w1
	local y2 = h1
	local x3 = math.max(x2, w - w3)
	local y3 = math.max(y2, h - h3)

	return 0, 0, x2, y2, x3, y3, w, h
end


-- * / Mesh helpers *


return quadSlice
