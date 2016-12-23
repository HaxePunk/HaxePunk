HaxePunk 4.0 Migration Guide
============================

4.0.0
-----

- There is no longer a `com.haxepunk` package; everything is now in `haxepunk`.
    - Imports are mostly backwards compatible: there is a macro which will convert `import com.haxepunk.*` imports into `haxepunk.*` imports. This may not work when importing a single type from a differently named file (`import com.haxepunk.Graphic.ImageType`). Similarly, if you use `import haxepunk.*` for new projects, they will be converted to `import com.haxepunk.*` when using HaxePunk 2.6, so new-style `haxepunk.*` imports should be preferred.
    - Metadata such as `@:access(com.haxepunk)` will need to be replaced with `@:access(haxepunk)`.
- To reduce bloat in HXP, utility functions have been moved:
    - All math functions are now found in `haxepunk.utils.MathUtil`
    - Random number functions are in `haxepunk.utils.Random`
    - Color-related functions are part of the `haxepunk.utils.Color` abstract
- Input-related classes have been moved from `com.haxepunk.utils` to `haxepunk.input`.
- Some `haxepunk.utils.Draw` functions have been removed. It's possible they will be reimplemented using the new renderer at a later date, but this is not currently a priority.
- Some classes have been deprecated or removed:
    - `com.haxepunk.World` (use `haxepunk.Scene`)
    - `com.haxepunk.graphics.Stamp` (use `haxepunk.graphics.Image`)
