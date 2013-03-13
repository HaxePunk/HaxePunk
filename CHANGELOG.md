HaxePunk CHANGELOG

v2.1.1
------------------------------
* [stevedecoded] Added Entity.moveAtAngle
* [nadako] Fixed Scene not working (World officially deprecated)
* Improved Atlas memory management

v2.1.0
------------------------------
* Major performance improvements on native targets
* Text is hardware accelerated
* Hardware acceleration is turned on automatically for every graphic class
* Renamed World to Scene (although World still exists as a wrapper)
* Multitouch support
* Added Atlas functions (destroy, destroyAll, count)
* [scriptorum] Updated keycodes for NME 3.5.5
* [YAYitsAndrew] Fixed image scaling factor
* [YAYitsAndrew] added HXP.alarm and delay support to HXP.tween
* Fixed console watch order
* Added default HaxePunk icon for new projects
* Image.createRect and Image.createCircle work on all targets

v2.0.3
------------------------------
* Added clipping to Atlas regions
* Added drawCallThreshold and smooth variables to Atlas (improves rendering)

v2.0.2
------------------------------
* Bug fixes for x/y scaling values
* World.getClass handles any input class (for interfaces)

v2.0.1
------------------------------
* Fixed Tilemap rendering when camera moves (cpp/neko)
* Initializing _count in Masklist to prevent neko crash
* [AndyLi] Correctly resize the source of Text

v2.0.0
------------------------------
* Hardware acceleration using TextureAtlas and the display list
* [DelishusCake] moveBy now checks moveCollideX/Y before moving

v1.7.2
------------------------------
* [MattTuttle] Improved joystick support (multiple axis, pressed/checked buttons)
* [MaskedPixel] Fixed inline HXP.colorLerp on native targets
* [MattTuttle] Updated to work with NME 3.5.x
* [Lythom|MattTuttle] Added mouseWheelDelta and mouseCursor to Input class
* [MattTuttle] Fixed drawToScreen when blendMode is null
* [MattTuttle] Reorganized template assets folder

v1.7.1
------------------------------
* Get mouseX/mouseY correctly even when FP.screen is translated/rotated
* Enforce frame index to stay within frame count boundaries
* Refactor FP.approach and FP.clamp to return sooner
* Prevent multiline Text objects from having final line cut off
* [MattTuttle] Masklist supports Circle/Polygon and debugDraw
* [MaskedPixel] fixed infinite loop when calling removeTween on the same tween

v1.7.0
------------------------------
* [Lythom] world.collidePoint returns the topmost entity
* [YAYitsAndrew] Tween.cancel added from FlashPunk
* [zlumer/MattTuttle] Tween handles events (start, update, finish)
* [MaskedPixel] Image originX/Y corrected to match FlashPunk
* [MattTuttle/tangzero] Improved template creation (haxelib run HaxePunk new ...)
* [MaskedPixel] Merged several changes from FlashPunk to HaxePunk
* [MattTuttle] haxelib uses include.nmml file
* [MattTuttle] addGraphic no longer creates a list when graphic=null
* [MattTuttle] console can be removed entirely from a build

v1.6.7
------------------------------
* [jgroeneveld] HXP.tween fix for native targets
* [jgroeneveld] Fixed spritemap for native targets
* [andyli] API improvements and for loop optimizations
* [MaskedPixel] Fixed entities missing world reference when remove called
* [MaskedPixel] Entity can have instance names
* Added a new preloader, requires gfx/preloader folder

v1.6.6
------------------------------
* Entity.addGraphic now correctly adds the new graphic if a list is created
* Fixed text resizing when wordwrap is true and resizable is false
* Removed automatic extensions from Sfx class
* VarTween and MultiVarTween now support properties
* Fixed more initialization errors in neko

v1.6.5
------------------------------
* Improved console output (memory usage, handles properties, terminal output)
* Added HXP.round for rounding to the nearest decimal
* Added width/height to Stamp [mkosler]

v1.6.4
------------------------------
* Fixed black background on Text graphics
* Updated Text class with extra options
* scaleHeight in Entity is now scaledHeight
* Console draws properly when window resizes
* Added global tweener
* Functions added for focus gained/lost
* Added Draw.text
* Fixed several neko bugs

v1.6.3
------------------------------
* bug fixes to Circle/Mask collision
* setHitboxTo now properly sets the entity dimensions
* improved examples
* removed unnecessary property getter/setter functions
* general code cleanup

v1.6.2
------------------------------
* [MarekkPie] moveBy/moveTowards can now handle Array<String> as well as String values.
* added version info to first line of the console log
* Tilemap constructor now handles asset strings
* added platformer example project
* fixed several neko crash bugs (initialize to zero)
* Image.createRect fixed so it no longer creates a transparent image
* fixed circle-circle collision
* improved BitmapData size restrictions for flash10

v1.6.1
------------------------------
* Fixed compilation errors for neko and html5 targets
* Changed grid to use a boolean array instead of BitmapData
* Added HXP.createBitmap to handle BitmapData creation. It checks dimensions and converts the color format in neko
* Minor adjustments to build.xml to ease development
* Fixed flash.Capabilities compile error for html5 target

v1.6.0
------------------------------
* Screen can now be resized. This is done by destroying the BitmapData buffer object and recreating it.
* Fixed several crash bugs in cpp targets

v1.5.0
------------------------------
* Initial port
