HaxePunk Major Version Migration Guide
======================================

Rename com.haxepunk.* to haxepunk.*
-----------------------------------

Imports are mostly backwards compatible: there is a macro which will convert `import com.haxepunk.*` imports into `haxepunk.*` imports. This may not work when importing a single type from a differently named file (`import com.haxepunk.Graphic.ImageType`). Similarly, if you use `import haxepunk.*` for new projects, they will be converted to `import com.haxepunk.*` when using HaxePunk 2.6, so new-style `haxepunk.*` imports should be preferred.

*Metadata such as `@:access(com.haxepunk)` will need to be replaced with `@:access(haxepunk)`.*

HXP utility functions
---------------------

To reduce bloat in HXP, utility functions have been moved to other classes.

- All math functions are now found in `haxepunk.utils.MathUtil`
- Random number functions are in `haxepunk.utils.Random`
- Color-related functions are part of the `haxepunk.utils.Color` abstract

haxepunk.utils.Draw
-------------------

Some functions have been removed. It's possible they will be reimplemented using the new renderer at a later date, but this is not currently a priority.

Class Changes
---------------

| 2.x                              | 4.x                         |
|----------------------------------|-----------------------------|
| com.haxepunk.World               | haxepunk.Scene              |
| com.haxepunk.graphics.Canvas     | *removed*                   |
| com.haxepunk.graphics.Stamp      | haxepunk.graphics.Image     |
| com.haxepunk.utils.Input         | haxepunk.input.Input        |
| com.haxepunk.utils.Key           | haxepunk.input.Key          |
| com.haxepunk.utils.Touch         | haxepunk.input.Touch        |
| com.haxepunk.utils.Joystick      | haxepunk.input.Joystick     |

Flash No Longer Supported
-------------------------

The decision was made to remove Flash support from HaxePunk 4. If you still need to compile for Flash please use the latest 2.x version.
