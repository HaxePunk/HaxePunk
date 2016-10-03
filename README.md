[![Build Status](https://img.shields.io/travis/HaxePunk/HaxePunk/dev.svg?style=flat)](https://travis-ci.org/HaxePunk/HaxePunk)
[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE)
[![Haxelib](https://img.shields.io/github/tag/haxepunk/haxepunk.svg?style=flat&label=haxelib)](http://lib.haxe.org/p/haxepunk)
[![Join the chat at https://gitter.im/HaxePunk/HaxePunk](https://badges.gitter.im/HaxePunk/HaxePunk.svg)](https://gitter.im/HaxePunk/HaxePunk?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

# HaxePunk

A Haxe port of the [FlashPunk](http://useflashpunk.net) AS3 library. There are a few additions/differences from the original.

* Builds for Flash, Windows, Mac, Linux, iOS, Android, and Ouya
* Circle/Polygon masks
* Hardware acceleration for native targets
* Joystick and multi-touch input
* Texture atlases for native targets (supports TexturePacker xml)

## Release build

First, make sure you have [Haxe](http://haxe.org) 3.0 or higher, we recommend you to update to Haxe 3.2 if you haven't already. Then execute the following commands below to get started with your first HaxePunk project.
If you are using Haxe 2 the last version supporting it was [v2.3.0](https://github.com/HaxePunk/HaxePunk/releases/tag/v2.3.0) `haxelib install HaxePunk 2.3.0`.

```bash
haxelib install HaxePunk
haxelib run HaxePunk setup
haxelib run HaxePunk new MyProject # creates a new project
```

## Development build

Make sure you set a default program for swf files to view the debug output. You will also need a C++ compiler for native builds (Xcode, Visual Studio, g++).

```bash
git clone https://github.com/HaxePunk/HaxePunk.git
make
```

This will build documentation, run unit tests, and run the example project. If you fix an issue, feel free to create a pull request.

If you've cloned locally, you can set your local repo as a development directory accessible through Haxelib:

```bash
git clone https://github.com/HaxePunk/HaxePunk.git
haxelib dev HaxePunk HaxePunk/
```

To disable the dev directory for HaxePunk simply run the command `haxelib dev HaxePunk`. Notice there is no third argument passed.

If you just want to install the latest dev version from Git, you can also do this with haxelib:

```bash
haxelib git HaxePunk https://github.com/HaxePunk/HaxePunk.git dev
```

## Have questions or looking to get involved?

There are a few ways you can get involved with HaxePunk.

* Come chat with us on [Gitter](https://gitter.im/HaxePunk/HaxePunk).
*	Drop by the [HaxePunk forum](http://forum.haxepunk.com) to ask a question or show off what you've created.
*	Create an issue or pull request or take part in the discussion.
*	Follow us on Twitter: [@HaxePunk](https://twitter.com/intent/user?screen_name=HaxePunk)

## Credits

*	Chevy Ray Johnston for creating the original FlashPunk.
*	[OpenFL](http://www.openfl.org/) makes native targets possible and simplifies asset management in Flash. Thanks guys!
*	All the awesome people who have [contributed](https://github.com/HaxePunk/HaxePunk/graphs/contributors) to HaxePunk and joined in the discussions on the [forum](http://forum.haxepunk.com).

## MIT License

Copyright (C) 2012-2016 HaxePunk contributors

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
