[![Build Status](https://img.shields.io/travis/HaxePunk/HaxePunk/release-3.0.0.svg?style=flat)](https://travis-ci.org/HaxePunk/HaxePunk) [![MIT License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE) [![Haxelib](https://img.shields.io/github/tag/haxepunk/haxepunk.svg?style=flat&label=haxelib)](http://lib.haxe.org/p/haxepunk)

# HaxePunk

A Haxe game engine, inspired by the [FlashPunk](http://useflashpunk.net) AS3 library.

This is the development branch for the 3.0 version, therefor it isn't stable, the api might change without notice
and it may not even build.

## Development build

Make sure you set a default program for swf files to view the debug output. You will also need a C++ compiler for native builds (Xcode, Visual Studio, g++).

```bash
git clone https://github.com/HaxePunk/HaxePunk.git -b release-3.0.0
haxelib dev HaxePunk HaxePunk
```

This will download this dev version of HaxePunk and install it through haxelib,
~~run unit tests, and build an example project for flash/neko/native~~.
If you fix an issue, feel free to create a pull request.

~~Generating documentation is just as simple. Run the commands below to create a new set of docs with haxedoc
The documentation will be located in doc/docs/, simply open doc/docs/index.html with your web browser to see the doc.~~

## Have questions or looking to get involved?

There are a few ways you can get involved with HaxePunk.

*	Drop by the [HaxePunk forum](http://forum.haxepunk.com) to ask a question or show off what you've created.
*	Create an issue or pull request or take part in the discussion.
*	Follow us on Twitter: [@HaxePunk](https://twitter.com/intent/user?screen_name=HaxePunk)

## Credits

*	Chevy Ray Johnston for creating the original FlashPunk.
*	[OpenFL](http://www.openfl.org/) makes native targets possible and simplifies asset management in Flash. Thanks guys!
*	All the awesome people who have [contributed](https://github.com/HaxePunk/HaxePunk/graphs/contributors) to HaxePunk and joined in the discussions on the [forum](http://forum.haxepunk.com).

## MIT License

Copyright (C) 2012-2015 HaxePunk contributors

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
