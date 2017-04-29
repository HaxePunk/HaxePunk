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
| com.haxepunk.utils.Joystick      | haxepunk.input.Gamepad      |

Flash No Longer Supported
-------------------------

The decision was made to remove Flash support from HaxePunk 4. If you still need to compile for Flash please use the latest 2.x version.

Input Changes
-------------

Input-related functionality has moved into the haxepunk.input package, and everything related to specific input types has been moved to its own class (haxepunk.input.Mouse, haxepunk.input.Key...)

With the refactored input system, you can define inputs from multiple sources as a single action within your game:

```
Key.define("left", [Key.LEFT, Key.A]);
myGamepad.defineButton("left", [PS3_CONTROLLER.DPAD_LEFT]);
myGamepad.defineAxis("left", PS3_CONTROLLER.LEFT_ANALOGUE_X, -0.1, -1);
Mouse.define("left", MouseButton.LEFT);
```

These can then be checked using `Input.check("left")`, `Input.pressed("left")`, or `Input.released("left")`

Both the Engine (for global controls) and the Scene (for Scene-specific controls) also have `inputPressed` and `inputReleased` signals that you can bind callbacks to: `scene.inputPressed.left.bind(myFunction)`.
