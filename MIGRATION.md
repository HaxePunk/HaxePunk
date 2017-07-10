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

| 2.x                                   | 4.x                                   |
|---------------------------------------|---------------------------------------|
| com.haxepunk.World                    | haxepunk.Scene                        |
| com.haxepunk.graphics.Backdrop        | haxepunk.graphics.tile.Backdro        |
| com.haxepunk.graphics.BitmapText      | haxepunk.graphics.text.BitmapText     |
| com.haxepunk.graphics.Canvas          | *removed*                             |
| com.haxepunk.graphics.Emitter         | haxepunk.graphics.emitter.Emitter     |
| com.haxepunk.graphics.Stamp           | haxepunk.graphics.Image               |
| com.haxepunk.graphics.Text            | haxepunk.graphics.text.Text           |
| com.haxepunk.graphics.TiledImage      | haxepunk.graphics.tile.TiledImage     |
| com.haxepunk.graphics.TiledSpritemap  | haxepunk.graphics.tile.TiledSpritemap |
| com.haxepunk.graphics.Tilemap         | haxepunk.graphics.tile.Tilemap        |
| com.haxepunk.utils.Input              | haxepunk.input.Input                  |
| com.haxepunk.utils.Key                | haxepunk.input.Key                    |
| com.haxepunk.utils.Touch              | haxepunk.input.Touch                  |
| com.haxepunk.utils.Joystick           | haxepunk.input.Gamepad                |

Flash No Longer Supported
-------------------------

The decision was made to remove Flash support from HaxePunk 4. If you still need to compile for Flash please use the latest 2.x version.

Input Changes
-------------

Input-related functionality has moved into the haxepunk.input package, and everything related to specific input types has been moved to its own class (haxepunk.input.Mouse, haxepunk.input.Key...)

With the refactored input system, you can define inputs from multiple sources as a single action within your game:

```haxe
Key.define("left", [Key.LEFT, Key.A]);
myGamepad.defineButton("left", [PS3_CONTROLLER.DPAD_LEFT]);
myGamepad.defineAxis("left", PS3_CONTROLLER.LEFT_ANALOGUE_X, -0.1, -1);
Mouse.define("left", MouseButton.LEFT);
```

These can then be checked using `Input.check("left")`, `Input.pressed("left")`, or `Input.released("left")`

Both the Engine (for global controls) and the Scene (for Scene-specific controls) also have `inputPressed` and `inputReleased` signals that you can bind callbacks to: `scene.inputPressed.left.bind(myFunction)`.

Tween Events
------------

Previously tween events were dispatched but are now using signals. Instead of passing a `complete` function to the tween when constructing it you'll need to bind to the signal instead.

```haxe
var tween = new Tween(10, onComplete); // old style

var tween = new Tween(10);
tween.onComplete.bind(onComplete); // new style
```

In addition to the complete function you can also bind to start and update.

```haxe
var tween = new Tween(10);
tween.onStarted.bind(function() trace("Tween started!"));
tween.onUpdated.bind(function() trace("Tween updated!"));
```

HXP Statics
-----------

Several static variables in HXP have either been removed or moved to a different class.

| 2.x              | 4.x                                                          |
|------------------|--------------------------------------------------------------|
| HXP.bounds       | Removed                                                      |
| HXP.camera       | Scene owns camera objects now                                |
| HXP.console      | In Engine but for internal use                               |
| HXP.entity       | Removed                                                      |
| HXP.halfWidth    | Removed                                                      |
| HXP.halfHeight   | Removed                                                      |
| HXP.resetCamera  | Removed                                                      |
| HXP.resize       | Removed                                                      |
| HXP.setCamera    | Removed                                                      |
| HXP.scene        | Removed because more than one scene can be active at a time. |
| HXP.sprite       | Removed                                                      |
| HXP.stage        | Removed (Using Stage class not advised)                      |
| HXP.timeFlag     | Moved to Timer.flag                                          |

Managing Scenes
---------------

HaxePunk can now render more than one scene at a time. If a scene is added to HaxePunk on top of another scene with a transparent background it will also render the underlying scene. This can be useful for ui overlays in a game. Due to this change, the way you add/remove scenes is a bit different than before.

### Old Way
```haxe
HXP.scene = new MyScene();
```

### New Way
```haxe
HXP.engine.replace(new MyScene()); // replaces ALL scenes
var overlay = new Overlay();
HXP.engine.add(overlay); // add another scene on top of the current one
// ...later in your code...
HXP.engine.remove(overlay); // remove the overlay
```
