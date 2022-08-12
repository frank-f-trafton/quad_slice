# QuadSlice Changelog

## v1.0.0 (2022\-08\-12)

* Added mesh helpers: `quadSlice.getTextureUV()` and `quadSlice.getStretchedVertices()`. Added `test_mesh_render.lua` to test these new functions. There are so many ways to set up and draw a mesh that attempting to handle it in-library would just get in the way, so that part is left to the library user.

* Removed section of README with (probably overblown) concerns about potential seams between tiles. I personally haven't encountered seams in my own testing so far, so long as the drawing coordinates and dimensions are floored to integers. I tested drawing a single-pixel texture with nearest-neighbor filtering, at a slowly-increasing sub-pixel position, and noted that it is rounded at the halfway point between integers. I think I had this conflated with a separate issue that I experienced with SpriteBatched tilemaps. Here is the passage:

```
* The stretchy tiles in the mosaic are scaled with the `sx` and `sy` arguments in `love.graphics.draw`. I haven't encountered any visible seams between tiles in my testing, but I also haven't ruled out the possibility. (Todo: somehow test every possible size and floored scale value, up to a certain threshold, I guess.) If you do run into seams, verify that you are drawing at a per-pixel or per-dpi-scaled-pixel level, that you are flooring the dimensions to the pixel grid, and try making the center tiles power-of-two sized, as floating point seems to be pretty good at storing n/po2 fractions. Linear filtering may also help to mask the issue. Worst case: you can make the center tile 1x1 pixels in size, so that `sx` and `sy` become `max(0, w - (w1+w3))` and `max(0, h - (h1+h3))` respectively. Anyways, I'll be back once I've done some more testing on this.
```

* Started changelog. (Previous version was a beta.)
