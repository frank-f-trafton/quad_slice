# quad\_slice


**VERSION:** 1.1.0 *(see CHANGELOG.md for breaking changes from 1.0.0)*


QuadSlice is a basic 9slice drawing library for LÖVE, intended for 2D menu panels and buttons.


![screen_quad_slice](https://user-images.githubusercontent.com/23288188/184142728-87a97b4e-e0a2-4c34-bac8-50f3c1f5d45f.png)


## Usage Example


```lua
local quadSlice = require("quad_slice")

local image = love.graphics.newImage("demo_res/9s_image.png")

-- (The 9slice starts at at 32x32, and has 64x64 corner tiles and an 8x8 center.)
local slice = quadSlice.new9Slice(32,32, 64,64, 8,8, 64,64, image:getWidth(), image:getHeight())

function love.draw()
	local mx, my = love.mouse.getPosition()

	quadSlice.draw(image, slice, 32, 32, mx - 32, my - 32)
end
```


## Features


* Can draw 9slices with `love.graphics.draw`, or add them to a [LÖVE SpriteBatch](https://love2d.org/wiki/SpriteBatch)

* Support for mirroring the right column and/or bottom row of tiles

* Helper functions to get UV and vertex coordinates for [LÖVE mesh objects](https://love2d.org/wiki/Mesh).


## Limitations


* All tiles for a given 9slice must be located on the same texture / spritesheet

* Repeating patterns for the center and edge tiles are not supported (though drawing a repeating pattern in the center isn't too difficult, if you're willing to break autobatching -- see `test_rep_pattern.lua` for an example).

* 9slices may have artifacts if you draw at a non-integer scale, or otherwise use coordinates or dimensions that are "off-grid."


## Functions: Slice table creation


### quadSlice.new9Slice

Creates a new 9slice definition.


*Function Signature:*


`quadSlice.new9Slice(x,y, w1,h1, w2,h2, w3,h3, iw,ih)`


*Arguments:*


* `x`: Left X position of the tile mosaic within the texture.

* `y`: Top Y position of the tile mosaic.

* `w1`: Width of the left column of tiles. (Must be > 0)

* `h1`: Height of the top row of tiles. (Must be > 0)

* `w2`: Width of the middle column of tiles. (Must be > 0)

* `h2`: Height of the middle row of tiles. (Must be > 0)

* `w3`: Width of the right column of tiles. (Must be > 0)

* `h3`: Height of the bottom row of tiles. (Must be > 0)

* `iw`: Width of the reference image.

* `ih`: Height of the reference image.


*Returns:* a 9slice definition table.


*Example:*


```lua
local slice = quadSlice.new9Slice(0,0, 16,16, 4,4, 16,16, my_image:getDimensions())
```


## Functions: Slice positioning and drawing


### quadSlice.setQuadMirroring


Modifies the quads in a 9slice by mirroring the right column and/or bottom row with those on the opposite side. The image used must have the `mirroredrepeat` [WrapMode](https://love2d.org/wiki/WrapMode) set on the desired axes.


*Function Signature:*


`quadSlice.setQuadMirroring(slice, hori, vert)`


*Arguments:*


`slice`: The 9slice to modify.

`hori`: When true, the right column mirrors the left column.

`vert`: When true, the bottom row mirrors the top row.

*Returns:* Nothing.


*Notes:*


* Mirroring can be un-done by calling the function again with *false* for `hori` and/or `vert`.

* The 9slice table does not keep track of mirroring state (as in, there are no flags in the 9slice table that indicate the current mirroring).

* This doesn't apply to the mesh helper functions, which don't use quads.


### quadSlice.draw


Draws a 9slice using calls to `love.graphics.draw`.


*Function Signature:*


`quadSlice.draw(image, slice, x, y, w, h, hollow)`


*Arguments:*


`image`: The image to use.

`slice`: The 9slice definition table.

`x`: X position for drawing.

`y`: Y position for drawing.

`w`: Width of the mosaic to draw.

`h`: Height of the mosaic to draw.

`hollow`: *(boolean, optional)* When true, prevents the center tile from being drawn. Can be used to frame other visual entities.


*Returns:* Nothing.


*Notes:*


* If `w` or `h` are <= 0, then nothing is drawn. You can reverse a 9slice by translating and flipping the LÖVE coordinate system (passing -1 as one or both arguments to [love.graphics.scale](https://love2d.org/wiki/love.graphics.scale)) and offsetting by the desired width and height:


```lua
function love.draw()
	local x, y, w, h = 64, 64, 128, 128

	love.graphics.translate(math.floor(x + w/2), math.floor(y + h/2))
	love.graphics.scale(-1, -1) -- flips on both axes

	quadSlice.draw(image, slice, -w/2, -h/2, w, h, false)
end
```


### quadSlice.batchAdd


Adds a 9slice to a [LÖVE SpriteBatch](https://love2d.org/wiki/SpriteBatch).


*Function Signature:*


`quadSlice.batchAdd(batch, slice, x, y, w, h, hollow)`


*Arguments:*


`batch`: The LÖVE SpriteBatch to append quads to.

`slice`: The 9slice to add.

`x`: Destination left X position within the batch.

`y`: Destination top Y position within the batch.

`w`: Width of the mosaic to add.

`h`: Height of the mosaic to add.

`hollow`: *(Optional, boolean)* When true, prevents the center tile (quad #5) from being added to the batch.


*Returns:* The index of the last quad added to the batch.


*Notes:*


* QuadSlice currently does not support adding reversed 9slices (as in, flipping or mirroring the entire mosaic) to SpriteBatches. You can reverse the SpriteBatch itself when drawing, but that also reverses all other quads added to it.


### quadSlice.batchSet


Sets 9slice quads within a [LÖVE SpriteBatch](https://love2d.org/wiki/SpriteBatch) at a given index. The indexes must already have been populated at an earlier time with sprites.


*Function Signature:*


`quadSlice.batchSet(batch, index, slice, x, y, w, h, hollow)`


*Arguments*


`batch`: The LÖVE SpriteBatch to append quads to.

`index`: Which index to start writing new sprite data to.

`slice`: The 9slice to set.

`x`: Destination left X position within the batch.

`y`: Destination top Y position within the batch.

`w`: Width of the mosaic to set.

`h`: Height of the mosaic to set.

`hollow`: When true, prevents the center tile from being set in the batch.


*Returns:* Nothing.


*Notes:*


* Be warned that when `hollow` is true, this function will set *eight* sprites, not nine.

* As with `batchAdd`, this function does not support reversed 9slices.


### quadSlice.getDrawParams


Gets parameters that are needed to draw a 9slice's quads at a desired width and height.


*Function Signature:*


`quadSlice.getDrawParams(slice, w, h)`


*Arguments:*


`slice`: The 9slice definition table.

`w`: Width of the 9slice that you want to draw.

`h`: Height of the 9slice that you want to draw.

*Returns:* Numerous arguments which are used in the `fromParams` drawing functions: `w1`, `h1`, `w2`, `h2`, `w3`, `h3`, `sw1`, `sh1`, `sw2`, `sh2`, `sw3`, and `sh3`.


*Notes:*


* This is really an internal function, but it's exposed in case you want to store some calculations when drawing multiple copies of a 9slice of the same dimensions.


### quadSlice.\*FromParams


Variations of `quadSlice.draw`, `quadSlice.batchAdd` and `quadSlice.batchSet` which take parameters returned by `quadSlice.getDrawParams`.


*Function Signatures:*


`quadSlice.drawFromParams(image, quads, hollow, x,y, w1,h1, w2,h2, w3,h3, sw1,sh1, sw2,sh2, sw3,sh3)`

`quadSlice.batchAddFromParams(batch, quads, hollow, x,y, w1,h1, w2,h2, w3,h3, sw1,sh1, sw2,sh2, sw3,sh3)`

`quadSlice.batchSetFromParams(batch, index, quads, hollow, x,y, w1,h1, w2,h2, w3,h3, sw1,sh1, sw2,sh2, sw3,sh3)`


*Arguments:*


`image`, `batch`, `index` and `hollow` are the same as in the main versions of these functions. `quads` is the internal sequence of quads from the 9slice (ie `slice.quads`).

`w1`: Calculated width of the left tile column.

`h1`: Calculated height of the top tile row.

`w2`: Calculated width of the middle tile column.

`h2`: Calculated height of the middle tile row.

`w3`: Calculated width of the right tile column.

`h3`: Calculated height of the bottom tile row.

`sw1`: Scale for the left tile column.

`sh1`: Scale for the top tile row.

`sw2`: Scale for the middle tile column.

`sh2`: Scale for the middle tile row.

`sw3`: Scale for the right tile column.

`sh3`: Scale for the bottom tile row.


*Returns:* Nothing.


## Functions: Mesh helpers


QuadSlice doesn't handle LÖVE meshes directly, but you can use these functions to get the raw vertex and UV coordinates for your own mesh setup and drawing code.


### quadSlice.getTextureUV


Gets UV offsets which can be used to populate a mesh.


*Function Signature:*


`quadSlice.getTextureUV(slice)`


*Arguments:*


`slice`: The 9slice object to read.


*Returns:* Four pairs of XY coordinates in the range of 0-1, which correspond to the edges around the columns and rows of the 9slice texture: `sx1`, `sy1`, `sx2`, `sy2`, `sx3`, `sy3`, `sx4`, and `sy4`.


*Notes:*

* Mirroring assigned with `setQuadMirroring` won't be detected here, as that is implemented by changing quad viewports, and none of the mesh helper functions touch quads at all. Tile mirroring with meshes can be achieved without using the `mirroredrepeat` WrapMode:


```lua
-- Horizontal
sx3, sx4 = sx2, sx1

-- Vertical
sy3, sy4 = sy2, sy1
```


### quadSlice.getStretchedVertices


Gets 9slice vertex positions for a given width and height.


*Function Signature:*


`quadSlice.getStretchedVertices(slice, w, h)`


*Arguments:*


`slice`: The 9slice object to read.

`w`: Width for the 9slice to be drawn.

`h`: Height for the 9slice to be drawn.


*Returns:* The following vertex positions: `x1`, `y1`, `x2`, `y2`, `x3`, `y3`, `x4`, and `y4`.


# MIT License


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
