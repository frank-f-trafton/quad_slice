# QuadSlice Changelog


## v1.3.1 (2025\-08\-08)

* Added draw functions:
  * `x0y0w3h2`: 3x2 top and middle
  * `x0y03h2_h`: 3x2 top and middle (hollow)
  * `x0y1w3h2`: 3x2 middle and bottom
  * `x0y1w3h2_h`: 3x2 middle and bottom (hollow)
  * `x0y0w2h3`: 2x3 left and middle
  * `x0y0w2h3_h`: 2x3 left and middle (hollow)
  * `x1y0w2h3`: 2x3 middle and right
  * `x1y0w2h3_h`: 2x3 middle and right (hollow)

* Fixed bad name for draw function `x0y0w1h3` (left column).

* Added more calls to local variables, namely `_lg_draw` for `love.graphics.draw`. The difference is tiny when running under LuaJIT (both compiled and interpreted), but it might help when LÖVE is compiled with PUC-Lua (which I believe is the case with love.js).

* Miscellaneous: minor updates to the README; changed the source code style a bit; updated the copyright date and name in the license text.


## v1.3.0 (2023\-07\-17)

**NOTE:** This is an API-breaking update.

* Rewrote the library to use the `__index` metamethod with a class table. See *upgrade guide* for a list of changed functions.

* Slice defs now support columns and rows with zero width and/or height, thus allowing for configurations like 3x1 bars.

* Added `Slice:setTileEnabled()` to allow toggling individual slice tiles.

* Removed the `hollow` argument in drawing functions. (Made redundant by `Slice:setTileEnabled()`.)

* Renamed `quadSlice.new9Slice()` to `quadSlice.newSlice()`.

* Added `quadSlice.draw_functions`, a table of alternative draw functions which omit certain tiles.

* Slice tables now keep track of mirroring state in the fields `slice.mirror_h` and `slice.mirror_v`. They should not be modified directly, but they are safe to read.


### Upgrade guide for v1.2.1 to v1.3.0

* Change any instances of `quadSlice.new9Slice()` to `quadSlice.newSlice()`.

* Calls to these functions need to be updated. A *[!]* indicates that the arguments list has changed beyond just using implicit `self`.

  * `quadSlice.getDrawParams()`: changed to `Slice:getDrawParams()`

  * `quadSlice.draw()`: changed to `Slice:draw()` *[!]*

  * `quadSlice.drawFromParams()`: changed to `Slice:drawFromParams()` *[!]*

  * `quadSlice.batchAdd()`: changed to `Slice:batchAdd()` *[!]*

  * `quadSlice.batchAddFromParams()`: changed to `Slice:batchAddFromParams()` *[!]*

  * `quadSlice.batchSet()`: changed to `Slice:batchSet()` *[!]*

  * `quadSlice.batchSetFromParams()`: changed to `Slice:batchSetFromParams()` *[!]*

  * `quadSlice.getTextureUV()`: changed to `Slice:getTextureUV()`

  * `quadSlice.getStretchedVertices()`: changed to `Slice:getStretchedVertices()`

  * `quadSlice.setQuadMirroring()`: changed to `Slice:setMirroring()`

* Any usage of the `hollow` argument needs to be rewritten, either by using `Slice:setTileEnabled(5, false)` or overwriting the slice's `drawFromParams` field with `quadSlice.draw_functions.hollow`.


## v1.2.1 (2023\-07\-16)

* Fixed incorrect default quad viewport assignments in `quadSlice.setQuadMirroring()`.


## v1.2.0 (2022\-08\-17)

**NOTE:** This is an API-breaking update.

* Functions no longer bail out early if `w` or `h` are <= 0. Instead, they enforce a minimum value of 0. You can now count on the functions which return values to always return *something*, even if the returned values would result in nothing visible being drawn.

Affected functions:

  * `quadSlice.getDrawParams` *(returns a slew of values)*

  * `quadSlice.draw`

  * `quadSlice.batchAdd` *(returns the index of the last sprite added to the batch)*

  * `quadSlice.batchSet`


### Upgrade guide for v1.1.0 to v1.2.0

* Any code that takes the return values of `quadSlice.getDrawParams` or `quadSlice.batchAdd` no longer has to guard against receiving `nil`. To simulate the old behavior, you can wrap the function call in an `if` statement that checks the width and height you would be passing in:


```lua
local w1,h1, w2,h2, w3,h3, sw1,sh1, sw2,sh2, sw3,sh3

if my_width > 0 and my_height > 0 then
	w1,h1, w2,h2, w3,h3, sw1,sh1, sw2,sh2, sw3,sh3 = quadSlice.getDrawParams(my_slice, my_width, my_height)
end
```


## v1.1.0 (2022\-08\-13)

**NOTE:** This is an API-breaking update.

* Reorganized the library to allow sharing 9slices among multiple compatible images. The use case is to help with UI skinning.

  * 9slice tables no longer contain an `image` field. Instead, they store a reference width and height (fields `iw` and `ih`).

  * Draw functions are modified to take a separate `image` reference.

* Removed `quadSlice.new9SliceMirrorH`, `quadSlice.new9SliceMirrorV`, and `quadSlice.new9SliceMirrorHV`. Replacing them is `quadSlice.setQuadMirroring`, which can be called on any existing 9slice table, and which is reversible.

* Added assertions for object creation and mirroring. Assertions are included for draw functions, though they are commented out by default due to overhead concerns. No assertions are provided for the mesh helper functions.


### Upgrade guide for v1.0.0 to v1.1.0

* Replace instances of `quadSlice.new9SliceMirrorH`, `quadSlice.new9SliceMirrorV`, and `quadSlice.new9SliceMirrorHV` with `quadSlice.new9Slice` followed by `quadSlice.setQuadMirroring`.

* Update arguments used in `quadSlice.new9Slice` (the first arg (`image`) was removed. Now it takes `iw` and `ih` as the last arguments, for the image's width and height, respectively).

* `quadSlice.draw`: Now takes an additional `image` variable as its first argument.

* `quadSlice.drawFromParams`: Now takes an `image` variable as its first argument, and the sequence of quads from a slice instead of the slice table itself. The `hollow` argument has been moved so that the results of `quadSlice.getDrawParams` can be included directly into the arguments list (in Lua, multi return values in an args list are cut off by any subsequent arguments).

* `quadSlice.batchAddFromParams`: Now takes the sequence of quads from a slice instead of the slice table itself. The `hollow` argument has been moved.

* `quadSlice.batchSetFromParams`: Now takes the sequence of quads from a slice instead of the slice table itself. The `hollow` argument has been moved.


## v1.0.0 (2022\-08\-12)

* Added mesh helpers: `quadSlice.getTextureUV()` and `quadSlice.getStretchedVertices()`. Added `test_mesh_render.lua` to test these new functions. There are so many ways to set up and draw a mesh that attempting to handle it in-library would just get in the way, so that part is left to the library user.

* Removed section of README with (probably overblown) concerns about potential seams between tiles. I personally haven't encountered seams in my own testing so far, so long as the drawing coordinates and dimensions are floored to integers. I tested drawing a single-pixel texture with nearest-neighbor filtering, at a slowly-increasing sub-pixel position, and noted that it is rounded at the halfway point between integers. I think I had this conflated with a separate issue that I experienced with SpriteBatched tilemaps. Here is the passage:

```
* The stretchy tiles in the mosaic are scaled with the `sx` and `sy` arguments in `love.graphics.draw`.
I haven't encountered any visible seams between tiles in my testing, but I also haven't ruled out the
possibility. (Todo: somehow test every possible size and floored scale value, up to a certain threshold,
I guess.) If you do run into seams, verify that you are drawing at a per-pixel or per-dpi-scaled-pixel
level, that you are flooring the dimensions to the pixel grid, and try making the center tiles power-of-
two sized, as floating point seems to be pretty good at storing n/po2 fractions. Linear filtering may
also help to mask the issue. Worst case: you can make the center tile 1x1 pixels in size, so that `sx`
and `sy` become `max(0, w - (w1+w3))` and `max(0, h - (h1+h3))` respectively. Anyways, I'll be back once
I've done some more testing on this.
```

* Started changelog. (Previous version was a beta.)
