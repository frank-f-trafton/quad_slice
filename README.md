# quad\_slice


**VERSION:** 1.311


QuadSlice is a 9-Slice drawing library for LÖVE.


![screen_quad_slice](https://user-images.githubusercontent.com/23288188/184142728-87a97b4e-e0a2-4c34-bac8-50f3c1f5d45f.png)


# Usage Example


```lua
local quadSlice = require("quad_slice")

local image = love.graphics.newImage("demo_res/9s_image.png")

-- (The 9slice starts at 32x32, and has 64x64 corner tiles and an 8x8 center.)
local slice = quadSlice.new9Slice(32,32, 64,64, 8,8, 64,64, image:getWidth(), image:getHeight())

function love.draw()
	local mx, my = love.mouse.getPosition()

	quadSlice.draw(image, slice, 32, 32, mx - 32, my - 32)
end
```


# Features

* Can draw 9-Slices with `love.graphics.draw` or add them to a [LÖVE SpriteBatch](https://love2d.org/wiki/SpriteBatch).

* Toggle the visibility of individual tiles.

* Mirroring of the right column and/or bottom row of tiles.

* Make 9-Slice subsets (3x1, 2x3, etc.) by specifying zero-width columns or zero-height rows.

* Helper functions to get UV and vertex coordinates for [LÖVE mesh objects](https://love2d.org/wiki/Mesh).


# Limitations

* All tiles for a given slice must be located on the same texture.

* No built-in support for repeating patterns in center or edge tiles. (Drawing a repeating pattern in the center isn't too difficult, if you're willing to break autobatching. See `test_rep_pattern.lua` for an example.)

* Slices may have artifacts if you draw at a non-integer scale, or otherwise use coordinates or dimensions that are "off-grid."


# Slice Defs

When creating a slice definition, you must provide coordinates and dimensions for a 3x3 grid which covers part of the texture you wish to draw: `x`, `y`, `w1`, `h1`, `w2`, `h2`, `w3`, and `h3`. From these coordinates, up to nine LÖVE Quads are generated and stored in an array:

```
   x    w1   w2   w3
y  +----+----+----+
   |q1  |q2  |q3  |
h1 +----+----+----+
   |q4  |q5  |q6  |
h2 +----+----+----+
   |q7  |q8  |q9  |
h3 +----+----+----+
```

If the width or height of a row or column is zero, then the associated tiles are given a shared, non-functional quad with dimensions of `0, 0`. The quad indices remain the same.

Note that due to tile mirroring, the LÖVE Quad positions and dimensions may not match the info stored in the slice table.


# API: QuadSlice

## quadSlice.newSlice

Creates a new slice definition.

`local slice = quadSlice.newSlice(x,y, w1,h1, w2,h2, w3,h3, iw,ih)`

* `x`, `y`: Left X and top Y positions of the tile mosaic in the texture.

* `w1`, `h1`: Width of the left column, and height of the top row. (Must be >= 0)

* `w2`, `h2`: Width of the middle column, and height of the middle row. (Must be >= 0)

* `w3`, `h3`: Width of the right column, and height of the bottom row. (Must be >= 0)

* `iw`, `ih`: Width and height of the reference image. (Should always be > 0)


**Returns:** a Slice definition table.


## quadSlice.populateAlternativeDrawFunctions

Builds and assigns alternative draw functions to `quadSlice.draw_functions`.

`quadSlice.populateAlternativeDrawFunctions()`

**Notes**:

* See **Alternative Draw Functions** for more info. This feature is not needed for general use of the library.


## quadSlice._mt_slice

The metatable for QuadSlice objects. You can check if a table is a QuadSlice with `getmetatable(some_table) == quadSlice._mt_slice`.


# API: Slice Objects


## Slice:setMirroring

Modifies the quads in a 9slice by mirroring the right column and/or bottom row with those on the opposite side. The image used must have the `mirroredrepeat` [WrapMode](https://love2d.org/wiki/WrapMode) set on the desired axes.

`Slice:setMirroring(mirror_h, mirror_v)`

* `mirror_h`: When true, the right column mirrors the left column.

* `mirror_v`: When true, the bottom row mirrors the top row.


**Notes:** Mirroring works by rewriting the viewport coordinates of certain quads.

* H-mirrored slices:

  * Quads 3, 6 and 9 are reversed versions of 1, 4 and 7, with negative X positions.


* V-mirrored slices:

  * Quads 7, 8 and 9 are reversed versions of 1, 2 and 3, with negative Y positions.


* HV-mirrored slices:

  * Quads 3 and 6 are h-flipped versions of 1 and 4.

  * Quads 7 and 8 are v-flipped versions of 1 and 2.

  * Quad 9 is an h-flipped and v-flipped version of 1.


## Slice:setTileEnabled

Enables or disables a tile within a slice.

`Slice:setTileEnabled(index, enabled)`

* `index`: The tile index.

* `enabled`: `true` to show the tile, `false` or `nil` to hide it.


**Notes:**

* Tile indices go left-to-right, top-to-bottom. Index #1 is the top-left tile.


## Slice:resetTiles

Resets the visibility of all tiles and refreshes their quad viewports.

`Slice:resetTiles()`


## Slice:draw

Draws a slice using calls to [love.graphics.draw](https://love2d.org/wiki/love.graphics.draw).

`Slice:draw(texture, x, y, w, h)`

* `texture`: The texture to use.

* `x`, `y`: Left X and top Y position for drawing.

* `w`, `h`: Width and height of the mosaic to draw.


**Notes:**

* If `w` or `h` are <= 0, then nothing visible will be drawn. You can reverse a slice by translating and flipping the LÖVE coordinate system (passing -1 as one or both arguments to [love.graphics.scale](https://love2d.org/wiki/love.graphics.scale)) and offsetting by the desired width and height:


```lua
function love.draw()
	local x, y, w, h = 64, 64, 128, 128

	love.graphics.translate(math.floor(x + w/2), math.floor(y + h/2))
	love.graphics.scale(-1, -1) -- flips on both axes

	slice:draw(texture, -w/2, -h/2, w, h)
end
```


## Slice:batchAdd

Adds a slice to a [LÖVE SpriteBatch](https://love2d.org/wiki/SpriteBatch).

`Slice:batchAdd(batch, x, y, w, h)`

* `batch`: The LÖVE SpriteBatch to append quads to.

* `x`, `y`: Destination left X and top Y position within the batch.

* `w`, `h`: Width and height of the mosaic to add.


**Returns:** The index of the last quad added to the batch.


**Notes:**

* QuadSlice does not support adding reversed slices (as in, flipping or mirroring the entire mosaic) to SpriteBatches. You can reverse the SpriteBatch itself when drawing, but that also reverses all other quads added to it.


## Slice:batchSet

Sets slice quads within a [LÖVE SpriteBatch](https://love2d.org/wiki/SpriteBatch) at a given index. The indices must already have been populated at an earlier time with sprites.

`Slice:batchSet(batch, index, x, y, w, h)`

* `batch`: The LÖVE SpriteBatch in which to set quads.

* `index`: The initial sprite index.

* `x`, `y`: Destination left X and top Y position within the batch.

* `w`, `h`: Width and height of the mosaic to set.


**Notes:**

* This method always sets nine sprites, even if the slice contains disabled tiles or zero-sized columns and rows.

* As with `Slice:batchAdd`, this function does not support reversed slices.


## Slice:getDrawParams

Gets parameters that are needed to draw a slice's quads at a desired width and height.

`local w1,h1, w2,h2, w3,h3, sw1,sh1, sw2,sh2, sw3,sh3 = Slice:getDrawParams(w, h)`

* `w`, `h`: Width and height of the slice that you want to draw.

**Returns:** Numerous arguments which are used in the `fromParams` drawing functions: `w1`, `h1`, `w2`, `h2`, `w3`, `h3`, `sw1`, `sh1`, `sw2`, `sh2`, `sw3`, and `sh3`.

**Notes:**

* This is really an internal function, but it's exposed in case you want to store some calculations when drawing multiple copies of a slice with the same dimensions.


## Slice:drawFromParams
## Slice:batchAddFromParams
## Slice:batchSetFromParams

Variations of `Slice:draw`, `Slice:batchAdd` and `Slice:batchSet` which take parameters returned by `Slice:getDrawParams`.

`Slice:drawFromParams(image, quads, x,y, w1,h1, w2,h2, w3,h3, sw1,sh1, sw2,sh2, sw3,sh3)`

`local index = Slice:batchAddFromParams(batch, quads, x,y, w1,h1, w2,h2, w3,h3, sw1,sh1, sw2,sh2, sw3,sh3)`

`Slice:batchSetFromParams(batch, index, quads, x,y, w1,h1, w2,h2, w3,h3, sw1,sh1, sw2,sh2, sw3,sh3)`

* `image`, `batch`, and `index` are the same as in the main versions of these functions. `quads` is the internal sequence of quads from the slice (ie `slice.quads`).

* `w1`, `h1`, `w2`, `h2`, `w3`, `h3`: Calculated dimensions of columns and rows.

* `sw1`, `sh1`, `sw2`, `sh2`, `sw3`, `sh3`: Drawing scale for each column and row.


## Slice:getTextureUV

Gets UV offsets which can be used to populate a mesh.

`local sx1,sy1, sx2,sy2, sx3,sy3, sx4,sy4 = Slice:getTextureUV()`

**Returns:** Four pairs of XY coordinates in the range of 0-1, which correspond to the edges around the columns and rows of the 9slice texture.

**Notes:**

* Mirroring assigned with `Slice:setMirroring` won't be detected here, as that is implemented by changing quad viewports, and none of the mesh helper functions touch quads at all.


## Slice:getStretchedVertices

Gets slice vertex positions for a given width and height.

`local x1,y1, x2,y2, x3,y3, x4,y4 = Slice:getStretchedVertices(w, h)`

* `w`, `h`: Width and height for the slice to be drawn.

**Returns:** The following vertex positions: `x1`, `y1`, `x2`, `y2`, `x3`, `y3`, `x4`, and `y4`.


# Alternative Draw Functions

QuadSlice provides alternative draw functions that render only certain quads. (Note that they have no impact on manual SpriteBatch or Mesh methods.) To use them, first initialize the functions after loading QuadSlice:

`quadSlice.populateAlternativeDrawFunctions()`

The functions are placed in `quadSlice.draw_functions`, with indices 0 through 511. In binary notation, the index represents which quads are rendered. Handily, LuaJIT allows us to write numbers in binary. For example, `quadSlice.draw_functions[0b111101111]` is a function that omits the central quad.

If your build of LÖVE wasn't compiled with LuaJIT, then add the numbers in this chart to get the index of the desired function:

```
	+----+----+----+
	|   1|   2|   4|
	+----+----+----+
	|   8|  16|  32|
	+----+----+----+
	|  64| 128| 256|
	+----+----+----+
```

…or, use a helper function like this:

```lua
local function _getDrawIndex(q1, q2, q3, q4, q5, q6, q7, q8, q9)
	return (q1 and 1 or 0)
		+ (q2 and 2 or 0)
		+ (q3 and 4 or 0)
		+ (q4 and 8 or 0)
		+ (q5 and 16 or 0)
		+ (q6 and 32 or 0)
		+ (q7 and 64 or 0)
		+ (q8 and 128 or 0)
		+ (q9 and 256 or 0)
end
```

Now, in your QuadSlice object, overwrite `slice.drawFromParams` with this function. To revert to the default draw function, overwrite it again with `nil`.

In older versions of QuadSlice, `quadSlice.draw_functions` was a table of hand-written functions with string keys. They almost doubled the size of the main source file on disk, they were difficult to review, and they didn't provide full coverage of the 512 variations. If you would prefer using the old function IDs, run the following snippet after calling `quadSlice.populateAlternativeDrawFunctions()`:

```lua
-- Old draw_functions behavior, from before version 1.311:
do
	local df = quadSlice.draw_functions
	quadSlice.draw_functions = {
		blank = df[0],
		center = df[16],
		corners = df[325],
		x0y0w3h1 = df[7], -- (top row)
		x0y1w3h1 = df[56], -- (middle row)
		x0y2w3h1 = df[448], -- (bottom row)
		x0y0w1h3 = df[73], -- (left column)
		x1y0w1h3 = df[146], -- (middle column)
		x2y0w1h3 = df[292], -- (right column)
		x0y0w2h2 = df[27], -- (2x2 upper-left)
		x1y0w2h2 = df[54], -- (2x2 upper-right)
		x0y1w2h2 = df[216], -- (2x2 bottom-left)
		x1y1w2h2 = df[432], -- (2x2 bottom-right)
		x1y0w1h2 = df[18], -- (1x2 middle + top)
		x1y1w1h2 = df[144], -- (1x2 middle + bottom)
		x0y1w2h1 = df[24], -- (2x1 middle + left)
		x1y1w2h1 = df[48], -- (2x1 middle + right)
		x0y0w3h2 = df[63], -- (3x2 top and middle)
		x0y03h2_h = df[47], -- (3x2 top and middle (hollow))
		x0y1w3h2 = df[504], -- (3x2 middle and bottom)
		x0y1w3h2_h = df[488], -- (3x2 middle and bottom (hollow))
		x0y0w2h3 = df[219], -- (2x3 left and middle)
		x0y0w2h3_h = df[203], -- (2x3 left and middle (hollow))
		x1y0w2h3 = df[438], -- (2x3 middle and right)
		x1y0w2h3_h = df[422], -- (2x3 middle and right (hollow))
		hollow_top = df[493], -- (3x3 hollow, open top)
		hollow_bottom = df[367], -- (3x3 hollow, open bottom)
		hollow_left = df[487], -- (3x3 hollow, open left)
		hollow_right = df[463], -- (3x3 hollow, open right)
		full = df[511], -- (3x3 full slice)
		hollow = df[495] -- (3x3 (hollow))
	}
end
```


# MIT License


Copyright (c) 2022 - 2025 RBTS / Frank F. Trafton

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
