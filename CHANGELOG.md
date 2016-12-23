HaxePunk CHANGELOG

v4.0.0
------------------------------

Major release; see MIGRATION.md for migration guide.

* [bendmorris] Removed com package
* [bendmorris] Reorganization of utility functions
* [bendmorris] Added NineSlice graphic
* [bendmorris] Added Color abstract
* [bendmorris] Text borders and shadows

v2.6.0
------------------------------
* [bendmorris] OpenFL 4 and NME support
* [bendmorris] Added EntityList
* [bendmorris] Particle scale, rotation and trails
* [bendmorris] Added semi-transparent scenes
* [bendmorris] Automatic screen scaling modes
* [bendmorris] Allow importing from either `com.haxepunk.*` or `haxepunk.*`
* [bendmorris] Added examples: asteroids, HXPBunnies, screenscale, text
* [EdgarMagdaleno] Custom cursor support
* [EdgarMagdaleno] Add Graphiclist get function
* [matrefeytontias] Fix Backdrop scaling issue
* [wselkin] Added BitmapFilter Array to TextOptions
* [wselkin] Other text improvements

v2.5.6
------------------------------
* [ibilon] Fix input update
* [ibilon] Guard onTouchMove against null object exception
* [icefoxen, ibilon] Update documentation

v2.5.5
------------------------------
* Adding README.md to zip for haxelib
* [Anheurystics] Fixed screen not clearing on HTML5
* [scriptorum] Added global volume/pan on native

v2.5.4
------------------------------
* Fixes for latest lime and openfl as well as Haxe 3.2
* [ibilon] Add Tilemap.createGrid
* [ibilon] Add Preloader progress bar container and allow preloader on html5
* [Anheurystics] Fixed HXP.next()
* [AbelToy] Added advanced tinting
* [ibilon] Allow setting type volume and pan during play
* [Oggzie] Fix addTween's start
* [VoEC] Fixing issues when flipping spritemaps
* [curlybrace1] Fixed error in Hitbox/Hitbox collision
* [gsarwohadi] Allow the use of runtime sound in Sfx
* [ibilon] Fix atlas creation when using default value for frame dimension in Spritemap
* [ibilon] Throw an exception instead of failling silently when asking for an invalid region (Atlas)
* [ibilon] Add error to Spritemap when frame dimensions are bigger than the image's dimensions
* [webninjasi] Fix searching on API docs
* [ibilon] Project creator now creates ide specific file as an option (FlashDevelop and Sublime)
* [jahndis] Fixed Image.createPolygon() to properly color the created Image
* [scriptorum] Fixed AtlasData memory leak
* [ibilon] Fixed Spritmap.stop when reset
* [ibilon] Do not apply gravity to particles when emitter isn't active
* [scriptorum] Fixed scene-changing
* [ibilon] Improve TextureAtlas load
* [scriptorum] Fixed tilemap.loadFrom2DArray, add ability to display transparent Tilemaps
* [ibilon] Fixed command call in setup tool
* [ibilon] Made lime-hybrid as default for now, fix tool documentation opening
* [scriptorum] Fixed Image.drawPolygon memory leak
* [ibilon] Replaced haxelib call to find haxelib.json with maco.Context.resolvePath
* [ibilon] Default smooth value of graphics classes if now set to false if stage quality is low, true otherwise

v2.5.3
------------------------------
* Update to latest lime, openfl and hxcpp
* Various internal improvements
* [MattTuttle] Deprecating HXP.blackColor
* [MattTuttle] Allow scenes to be pushed and popped
* [MattTuttle] Allow initializing an Image with a TileAtlas
* [Nananas] Ouya controller mapping for desktop
* [azrafe7] Fixes for masklist collisions
* [ibilon] Fix Text.addStyle on native
* [ibilon] Fix text and richText color change
* [ibilon] Fix parent null value in mask calculations
* [scriptorum] Added Spritemap support for playing adhoc animations
* [scriptorum] Added reset control to Spritemap.stop() Fixed stop()
* [ibilon] Fix tween callback
* [Anheurystics] Fixed Draw.graphic not working for native targets
* [ibilon] Can disable HaxePunk's preloader with -DnoHaxepunkPreloader
* [ibilon] Can play spritemap anim in reverse
* [MattTuttle] Fixing out of bounds error in insertSortedKey
* [MattTuttle] Fixing crash when type doesn't exist in types map
* [MattTuttle] Missing types no longer crash collide functions
* [eliasku] Update Ease.hx
* [bendmorris] Don't round drawing positions or sizes to integers
* [bendmorris] Fixing some buffer size and word wrap issues relating to font size and scale
* [bendmorris] Fix for functions like collidePoint that find elements by type
* [bendmorris] Adjust scaling of individual tiles to ensure no gaps or overlaps
* [bendmorris] Draw tilemap tiles starting from integer positions
* [Marc010] Add stop() function to Spritemap
* [Marc010] Ported Image.createPolygon() from Flashpunk
* [azrafe7] Added support to XNA (pixelizer) font to BitmapText
* [azrafe7] Fixed polygon collision
* [XXLTomate] Changed default flash background color to 0x00000000 to match native
* [XXLTomate] Use HXP.stage.color in Screen.hx as default color
* [Gama11] Joystick: update XBOX_GAMEPAD for OpenFL 1.4.0
* [azrafe7] BitmapFont: fixed some glyphs in default font
* [bendmorris] Embed assets by default on all platforms
* [azrafe7] Fixes and improvements for Polygon.removeDuplicateAxes()
* [bendmorris] Fixing emitter bugs when frameindex is outside the bounds of frame
* [bendmorris] Adding screen shake
* [bendmorris] Adding basic gesture controls for multitouch-enabled devices
* [bendmorris] Allow mixed rendering of both smoothed and non-smoothed graphics
* [lived123456] Update ParticleType.hx
* [zebbedy] Compensate for openfl text color bug on Android
* [bendmorris, ibilon] Fix image rotation when using uneven screen scalling in hardware rendermode
* [ibilon] Changed to dox for documentation generation

v2.5.2
------------------------------
* [bendmorris] Adding clear method to Emitter
* [bendmorris] Allow initializing an Image with a TileAtlas
* [MattTuttle] Fix CLI on windows
* [MattTuttle] Fix SlopedGrid collisions
* [MattTuttle] Grid mask optimizations
* [MattTuttle] Don't require parent for Hitbox/Circle
* [ibilon] Fix HXP.choose
* [bendmorris] Fix textWidth/textHeight calculation bug when BitmapText is scaled
* [bendmorris] Fix one line was sometimes being drawn twice on Flash BitmapText
* [bendmorris] Fix Scene.clearRecycledAll
* [Marc010] Fix Input Handling
* [Anheurystics] Fixed Draw.circle in HXP.HARDWARE bug
* [ibilon] Add update command
* [ibilon] Fix Tween addEventListener but doesn't remove it
* [azrafe7] HXP.INT_MIN/MAX_VALUE
* [azrafe7] Small fix for seed clamping
* [azrafe7] Inited min/max in Mask.project() with non-arbitrary values
* [azrafe7] Added rectPlus() to Draw
* [ibilon] Add flashdevelop project file to the new project template
* [ibilon] Use Array.indexOf if Haxe 3.1
* [azrafe7] Small fix for circle vs hitbox collision
* Updating dependencies

v2.5.1
------------------------------
* [andyli] Don't destroy graphic when Entity is removed
* [Nananas] Ouya game pad corrections
* [bendmorris] Fixing BitmapText textWidth/textHeight and word wrapping when font size changes
* [bendmorris] Optimizing Canvas/Tilemap when scale or color are set on Flash
* [MattTuttle] Pulled richText from FlashPunk into Text
* [MattTuttle] Improved grid debug rendering
* [steinarvk] Fixing AtlasRegion.clip from modifying the original Rectangle
* Various improvements to the HaxePunk core

v2.5.0
------------------------------
* [ibilon] Added setup command to run tool
* [bendmorris] Added BitmapText graphic class
* [azrafe7] Layers can be negative on all targets (removes HXP.BASELAYER)
* [bendmorris] Added Joystick.released to match Input
* [ibilon] Text now uses BitmapData for consistent rendering on all targets
* [MattTuttle] Fixed layer rendering for native targets
* [Nananas] Joystick on Ouya handles player id properly
* [MattTuttle] Added layer list for Console to toggle layer visibility
* [azrafe7] Fixed Circle and Polygon collisions with other masks
* Many more bug fixes and compatibility improvements

v2.4.6
------------------------------
* [azrafe7] Fixed Lambda.indexOf() memory leaks in flash
* [elnabo] Added possibility to make a copy of a grid
* Update for version 1.2.2 of openfl

v2.4.5
------------------------------
* [ibilon] Revert to normal error throwing (fixed in openfl)
* Update for version 1.2.1 of openfl

v2.4.4
------------------------------
* [elnabo] Allow to have spacing on tileset
* [elnabo] Added support for middle and right mouse button
* [bendmorris] Fixing Spritemap initialization bug on Linux64 target
* [ibilon] Allow Scene.create to take constructor arguments
* [ibilon] Entities can now follow the camera
* [ibilon] Fixed error throwing in non-flash targets + new unit test
* [azrafe7] Grid vs Grid collision ported from FlashPunk
* Update for version 1.2.0 of openfl

v2.4.3
------------------------------
* [ibilon] Can now resize stage in native
* [ibilon] Wrong debug draw for SlopedGrid
* [MattTuttle] Atlas.destroy cleans up cache propery
* [ibilon] Fix Text scale and visibility on native
* [ibilon] HXP.choose Fix
* Update for new version of openfl

v2.4.2
------------------------------
* [ibilon] Native screen smoothing
* [scriptorum] Fixed faulty Text dimensions
* [ibilon] Numpad keys with numlock off on native
* [ibilon] Change setField to setProperty in MultiVarTween to use properties setter
* [ibilon] Added warnings
* [ibilon] Image.createX check sizes
* [ibilon] Emit centered particles on flash
* Update for new version of openfl

v2.4.1
------------------------------
* [XXLTomate] Option to play an emitter animation backwards
* [XXLTomate] Fix invisible particles
* [kpaekn] Added Image.smooth getter and setter
* [ibilon] Smooth for non-flash target
* [ibilon] Fix doc generation script
* Update for new version of openfl

v2.4.0
------------------------------
* Speed improvements for openfl-bitfive
* Template improved to match asset folder names
* [fserb] Added ImageMask
* [XXLTomate] Added pause/resume function to Graphic
* [ibilon] Fix key mapping on native
* [ibilon] Tilemap and Canvas can be scaled
* Fix Flash memory leak (multitouch)
* [ibilon] Nameless images can be flipped
* [kpaekn] scaled images were not flipped correctly on native
* [ibilon] Image can take BitmapData on native
* [ibilon] Sound wouldn't stop at end on native
* [ibilon] Backdrop rendered one too many rows/columns
* Added Ouya controller mapping
* [ibilon] Trace capture is now optional for console
* [fserb] Fix canvas rendering on native
* [fserb] Tilemap rendering fixes
* [ibilon] destroy old graphic when changed
* [ibilon] Text alpha rendering fix
* Several additions from FlashPunk
* Improved documentation

v2.3.2
------------------------------
* [ibilon] Fix circle/grid collision
* [ibilon] Fix grid debug overlay
* [ibilon] Fix moveAtAngle
* [elnabo] Fix Tilemap/Grid load from array

v2.3.1
------------------------------
* [ibilon] Changed render mode to BUFFER for HTML5
* Matching OpenFL 2x2 matrix ordering change in 1.0.2
* [elnabo] Fixed/added load from array for Tilemap and Grid
* [ibilon] Allow setHitboxTo for all targets
* Allow renderMode to be set in Engine constructor
* Fixed seamless Sfx looping on native targets
* Added Xbox button configuration for Mac
* Fixing flipped images when angle != 0
* Changed joystick axis to start at 0 instead of 1

v2.3.0
------------------------------
* Adding OpenFL support
* [julsam] Xbox controller support
* [MaskedPixel] Improved scaling, atlas layer management
* [MALHCat] apply parent position to image render
* [squiddingme] spritemaps animate the same in fixed timestep mode
* Fixed Tilemap usePositions for native rendering
* Added HXP.fullscreen to toggle between windowed and fullscreen modes
* Various fixes from FlashPunk

v2.2.1
------------------------------
* (Native) Draw working on hardware targets
* (Native) PreRotation frameAngle renders correctly
* (Native) Image scale and origin matches Flash
* (Native) Added support for Emitter frames
* [XXLTomate] Fixed upper/lower case input
* [MaskedPixel] Fixed width/height for Image/Text
* [MaskedPixel] Fixed ghost text in Flash
* [thecodethinker] Added a cross method to Vector
* [DjPale] Check that scene exists in onCamera
* [julsam] Fix debug renderEntities when entity's scroll is != 1
* [julsam] Allow Draw.line() to draw out of the screen boundaries
* [XXLTomate] fixed memory leak for non flash targets
* (Native) Fixed Text.color
* [MaskedPixel] World.camera should be favored over HXP.camera

v2.2.0
------------------------------
* [raistlin] Ready for Haxe 3 and Neko 2
* PreRotation no longer throws null error on Flash
* HXP.RAD and HXP.DEG cause angles to spin the same on all targets
* Fixed tearing issues with scaled Tilemaps
* Fixed Text not showing and scaled position
* Added HXP.orientations to restrict orientation modes on mobile devices
* Debug draw for Grid looks correct in scaled scenes
* Atlases share rendering data for identical images
* [FlashPunk] Added filtered volume/pan to Sfx

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
