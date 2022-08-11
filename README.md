**NOTE:** This library is currently a beta.

# quad\_slice

QuadSlice is a basic 9slice drawing library for LÖVE, intended for 2D menu panels and buttons.

The main goal is to be easy to use: it should be possible to display a 9slice (provided you have a suitable image) in about a dozen lines of source code.


## Usage Example


```lua
local quadSlice = require("quad_slice")

local image = love.graphics.newImage("demo_res/9s_image.png")

-- (The 9slice starts at at 32x32, and has 64x64 corner tiles and an 8x8 center.)
local slice = quadSlice.new9Slice(image, 32,32, 64,64, 8,8, 64,64) -- x,y, w1,h1, w2,h2, w3,h3

function love.draw()
	local mx, my = love.mouse.getPosition()

	quadSlice.draw(slice, 32, 32, mx - 32, my - 32) -- x, y, w, h
end
```


## Features


* Can draw 9slices with `love.graphics.draw`, or add them to a [LÖVE SpriteBatch](https://love2d.org/wiki/SpriteBatch)

* Support for mirroring the right column and/or bottom row of tiles


## Limitations


* All tiles for a given 9slice must be located on the same texture / spritesheet

* Repeating patterns for the center and edge tiles are not supported (though drawing a repeating pattern in the center isn't too difficult, if you're willing to break autobatching -- see `test_rep_pattern.lua` for an example).

* 9slices may have artifacts if you draw at a non-integer scale, or otherwise use coordinates or dimensions that are "off-grid."

* The stretchy tiles in the mosaic are scaled with the `sx` and `sy` arguments in `love.graphics.draw`. I haven't encountered any visible seams between tiles in my testing, but I also haven't ruled out the possibility. (Todo: somehow test every possible size and floored scale value, up to a certain threshold, I guess.) If you do run into seams, verify that you are drawing at a per-pixel or per-dpi-scaled-pixel level, that you are flooring the dimensions to the pixel grid, and try making the center tiles power-of-two sized, as floating point seems to be pretty good at storing n/po2 fractions. Linear filtering may also help to mask the issue. Worst case: you can make the center tile 1x1 pixels in size, so that `sx` and `sy` become `max(0, w - (w1+w3))` and `max(0, h - (h1+h3))` respectively. Anyways, I'll be back once I've done some more testing on this.


## Functions: Slice table creation


### quadSlice.new9Slice

Creates a new 9slice definition.

*Function Signature:*


`quadSlice.new9Slice(image, x,y, w1,h1, w2,h2, w3,h3)`


*Arguments:*


* `image`: The texture containing the tile mosaic.

* `x`: Left X position of the tile mosaic within the texture.

* `y`: Top Y position of the tile mosaic.

* `w1`: Width of the left column of tiles. (Must be > 0)

* `h1`: Height of the top row of tiles. (Must be > 0)

* `w2`: Width of the middle column of tiles. (Must be > 0)

* `h2`: Height of the middle row of tiles. (Must be > 0)

* `w3`: Width of the right column of tiles. (Must be > 0)

* `h3`: Height of the bottom row of tiles. (Must be > 0)


*Returns:* a 9slice definition table.


*Example:*


```lua
local slice = quadSlice.new9Slice(my_image, 0,0, 16,16, 4,4, 16,16)
```


### quadSlice.new9SliceMirror\*


These are variations of `quadSlice.new9Slice` which mirror the right column and/or bottom row with tiles from the opposite end. The image used must have the `mirroredrepeat` [WrapMode](https://love2d.org/wiki/WrapMode) set on the desired axes -- `new9Slice*` does not set this automatically.


*Function Signatures:*


`quadSlice.new9SliceMirrorH(image, x,y, w1,h1, w2,h2, h3)`

`quadSlice.new9SliceMirrorV(image, x,y, w1,h1, w2,h2, w3)`

`quadSlice.new9SliceMirrorHV(image, x,y, w1,h1, w2,h2)`


*Arguments:*


The arguments are the same as `new9Slice()`, except that the dimensions of mirrored fields (third column and/or row) are missing.


*Returns:* a 9slice definition table.


## Functions: Slice positioning and drawing


### quadSlice.draw


Draws a 9slice.


*Function Signature:*


`quadSlice.draw(slice, x, y, w, h, hollow)`


*Arguments:*


`slice`: The 9slice definition table.

`x`: X position for drawing.

`y`: Y position for drawing.

`w`: Width of the mosaic to draw.

`h`: Height of the mosaic to draw.

`hollow`: When true, prevents the center tile (quad #5) from being drawn. Can be used to frame other visual entities.


*Returns:* Nothing.


*Notes:*


If `w` or `h` are <= 0, then nothing is drawn. You can reverse a 9slice by translating and flipping the LÖVE coordinate system (passing -1 as one or both arguments to [love.graphics.scale](https://love2d.org/wiki/love.graphics.scale)) and offsetting by the desired width and height:


```lua
function love.draw()
	local x, y, w, h = 64, 64, 128, 128

	love.graphics.translate(math.floor(x + w/2), math.floor(y + h/2))
	love.graphics.scale(-1, -1) -- flips on both axes

	quadSlice.draw(slice, -w/2, -h/2, w, h, false)
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

`hollow`: When true, prevents the center tile (quad #5) from being added to the batch.


*Returns:* The index of the last quad added to the batch.


*Notes:*


QuadSlice currently does not support adding reversed 9slices (as in, flipping or mirroring the entire mosaic) to SpriteBatches. You can reverse the SpriteBatch itself when drawing, but that also reverses all other quads added to it.


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

`hollow`: When true, prevents the center tile (quad #5) from being set in the batch.


*Returns:* Nothing.


*Notes:*


Be warned that when `hollow` is true, this function will set *eight* sprites, not nine.

As with `batchAdd`, this function does not support reversed 9slices.


### quadSlice.getDrawParams


Gets parameters that are needed to draw a 9slice at a desired width and height with [love.graphics.draw](https://love2d.org/wiki/love.graphics.draw).


*Function Signature:*


`quadSlice.getDrawParams(slice, w, h)`


*Arguments:*


`slice`: The 9slice definition table.

`w`: Width of the 9slice that you want to draw.

`h`: Height of the 9slice that you want to draw.

*Returns:* Numerous arguments which are used in the `fromParams` drawing functions: `w1`, `h1`, `w2`, `h2`, `w3`, `h3`, `sw1`, `sh1`, `sw2`, `sh2`, `sw3`, `sh3`


*Notes:*


This is really an internal function, but it's available publicly in case you want to store some calculations when drawing multiple copies of a 9slice of the same dimensions.


### quadSlice.\*FromParams


Variations of `quadSlice.draw`, `quadSlice.batchAdd` and `quadSlice.batchSet` which take parameters returned by `quadSlice.getDrawParams`.


*Function Signature:*


`quadSlice.drawFromParams(slice, x, y, w1, h1, w2, h2, w3, h3, sw1, sh1, sw2, sh2, sw3, sh3, hollow)`

`quadSlice.batchAddFromParams(batch, slice, x, y, w1, h1, w2, h2, w3, h3, sw1, sh1, sw2, sh2, sw3, sh3, hollow)`

`quadSlice.batchSetFromParams(batch, index, slice, x, y, w1, h1, w2, h2, w3, h3, sw1, sh1, sw2, sh2, sw3, sh3, hollow)`


*Arguments:*


`slice`, `batch`, `index`, and `hollow` are the same as in the main versions of these functions.

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
