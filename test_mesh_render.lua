-- Test rendering 9-Slices as textured LÖVE meshes.

local quadSlice = require("quad_slice")


-- This vertex map assumes that the "triangle" mesh mode is being used.
local vertex_map = {
	 1,  2,  5,  6,  5,  2, -- q1
	 2,  3,  6,  7,  6,  3, -- q2
	 3,  4,  7,  8,  7,  4, -- q3
	 5,  6,  9, 10,  9,  6, -- q4
	 6,  7, 10, 11, 10,  7, -- q5
	 7,  8, 11, 12, 11,  8, -- q6
	 9, 10, 13, 14, 13, 10, -- q7
	10, 11, 14, 15, 14, 11, -- q8
	11, 12, 15, 16, 15, 12, -- q9
}
--[[
	Maps to:

	1----2----3----4
	| q1 | q2 | q3 |
	5----6----7----8
	| q4 | q5 | q6 |
	9----10---11---12
	| q7 | q8 | q9 |
	13---14---15---16
--]]



-- Set up the 9-Slice as usual.
local image1 = love.graphics.newImage("demo_res/9s_image.png")
local slice1 = quadSlice.newSlice(32,32, 64,64, 8,8, 64,64, image1:getDimensions())


-- Calculate the UV details from the 9-Slice.
local slice_vertices
do
	local sx1, sy1, sx2, sy2, sx3, sy3, sx4, sy4 = slice1:getTextureUV()

	-- Test mirroring the right column and bottom row.
	-- 'mirroredrepeat' is not necessary for this when using a mesh.
	--[[
	sx3, sx4 = sx2, sx1
	sy3, sy4 = sy2, sy1
	--]]

	slice_vertices = {
		-- vx,vy, u,v, r,g,b,a
		{0,0, sx1,sy1, 1,1,1,1}, -- 1
		{0,0, sx2,sy1, 1,1,1,1}, -- 2
		{0,0, sx3,sy1, 1,1,1,1}, -- 3
		{0,0, sx4,sy1, 1,1,1,1}, -- 4
		{0,0, sx1,sy2, 1,1,1,1}, -- 5
		{0,0, sx2,sy2, 1,1,1,1}, -- 6
		{0,0, sx3,sy2, 1,1,1,1}, -- 7
		{0,0, sx4,sy2, 1,1,1,1}, -- 8
		{0,0, sx1,sy3, 1,1,1,1}, -- 9
		{0,0, sx2,sy3, 1,1,1,1}, -- 10
		{0,0, sx3,sy3, 1,1,1,1}, -- 11
		{0,0, sx4,sy3, 1,1,1,1}, -- 12
		{0,0, sx1,sy4, 1,1,1,1}, -- 13
		{0,0, sx2,sy4, 1,1,1,1}, -- 14
		{0,0, sx3,sy4, 1,1,1,1}, -- 15
		{0,0, sx4,sy4, 1,1,1,1}, -- 16
	}
end


-- Make the mesh and apply a 16-index vertex map and the UV coordinates.
local mesh = love.graphics.newMesh(#vertex_map, "triangles", "dynamic")
mesh:setTexture(image1)
mesh:setVertexMap(vertex_map)
mesh:setVertices(slice_vertices)


function love.keypressed(kc, sc, rep)
	if sc == "escape" then
		love.event.quit()
		return
	end
end


local function updateMesh(mesh, vertices, w, h)
	if w <= 0 or h <= 0 then return end

	local x1, y1, x2, y2, x3, y3, x4, y4 = slice1:getStretchedVertices(w, h)

	local sv = vertices

	-- Update vertex positions.
	sv[ 1][ 1], sv[ 1][ 2] = x1,  y1
	sv[ 2][ 1], sv[ 2][ 2] = x2,  y1
	sv[ 3][ 1], sv[ 3][ 2] = x3,  y1
	sv[ 4][ 1], sv[ 4][ 2] = x4,  y1

	sv[ 5][ 1], sv[ 5][ 2] = x1,  y2
	sv[ 6][ 1], sv[ 6][ 2] = x2,  y2
	sv[ 7][ 1], sv[ 7][ 2] = x3,  y2
	sv[ 8][ 1], sv[ 8][ 2] = x4,  y2

	sv[ 9][ 1], sv[ 9][ 2] = x1,  y3
	sv[10][ 1], sv[10][ 2] = x2,  y3
	sv[11][ 1], sv[11][ 2] = x3,  y3
	sv[12][ 1], sv[12][ 2] = x4,  y3

	sv[13][ 1], sv[13][ 2] = x1,  y4
	sv[14][ 1], sv[14][ 2] = x2,  y4
	sv[15][ 1], sv[15][ 2] = x3,  y4
	sv[16][ 1], sv[16][ 2] = x4,  y4

	mesh:setVertices(sv)

	return true
end


function love.draw()
	-- Move the mouse to resize the 9-Slice.
	local mx, my = love.mouse.getPosition()

	local w = mx - 64
	local h = my - 64

	if w > 0 and h > 0 then
		updateMesh(mesh, slice_vertices, w, h)
		love.graphics.draw(mesh, 64, 64)
	end
end


