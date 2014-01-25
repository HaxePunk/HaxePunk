# HaxePunk

A Haxe port of the [FlashPunk](http://useflashpunk.net) AS3 library. There are a few additions/differences from the original.

* Builds for Flash, Windows, Mac, Linux, iOS, Android, and Ouya
* Circle/Polygon masks
* Hardware acceleration for native targets
* Joystick and multi-touch input
* Texture atlases for native targets (supports TexturePacker xml)

[![Build Status](https://travis-ci.org/HaxePunk/HaxePunk.png?branch=master)](https://travis-ci.org/HaxePunk/HaxePunk)

## Release build

First, make sure you have [Haxe](http://haxe.org) 3.0 or higher. Then execute the following commands below to get started with your first HaxePunk project.
If you are using Haxe 2 the last version supporting it was [v2.3.0](https://github.com/HaxePunk/HaxePunk/releases/tag/v2.3.0) `haxelib install HaxePunk 2.3.0`.

```bash
haxelib install HaxePunk
haxelib run HaxePunk new MyProject # creates a new project
```

## Development build

You need to have ant installed to build a development version of HaxePunk. Make sure you set a default program for swf files to view the debug output. You will also need a C++ compiler for native builds (Xcode, Visual Studio, g++).

```bash
git clone git@github.com:HaxePunk/HaxePunk.git
ant
```

This will install a dev version of HaxePunk through haxelib, run unit tests, and build an example project for flash/neko/native. If you fix an issue, feel free to create a pull request.

Generating documentation is just as simple. Run the commands below to create a new set of docs with chxdoc. The first two commands are optional if you already have chxdoc installed.
The documentation will be located in doc/docs/, simply open doc/docs/index.html with your web browser to see the doc.

```bash
haxelib git chxdoc git@github.com:ibilon/chxdoc.git
haxelib run chxdoc install pathToYourHaxeFolder
ant doc
```

## Have questions or looking to get involved?

There are a few ways you can get involved with HaxePunk.

*	Drop by the [HaxePunk forum](http://forum.haxepunk.com) to ask something or show off what you've created.
*	Contact Matt directly
	*	Email: heardtheword (at) gmail (dot) com
	*	Twitter: @Matt_Tuttle

## Credits

*	Chevy Ray Johnston for creating the original FlashPunk.
*	[OpenFL](http://www.openfl.org/) makes native targets possible and simplifies asset management in Flash. Thanks guys!
*	All the awesome people who have [contributed](https://github.com/HaxePunk/HaxePunk/graphs/contributors) to HaxePunk and joined in the discussions on the [forum](http://forum.haxepunk.com).

## MIT License

Copyright (C) 2012-2014 Matt Tuttle

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
