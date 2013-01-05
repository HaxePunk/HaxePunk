# HaxePunk

A HaXe port of the [FlashPunk](http://flashpunk.net) AS3 library.

## Release build

First, make sure you have [HaXe](http://haxe.org) 2.10 or higher. You will need to also install [NME](http://haxenme.org) 3.5.3 or higher. The last step is to install HaxePunk through haxelib.

```bash
haxelib install HaxePunk
haxelib run HaxePunk new MyProject # creates a new project
```

## Development build

You need to have ant installed to build a development version of HaxePunk. Make sure you set a default program for swf files to view the debug output.

```bash
git clone git@github.com:MattTuttle/HaxePunk
ant
```

This will install a dev version of HaxePunk through haxelib, run several unit tests, and build an example project for flash/neko/js. If you fix an issue, feel free to create a pull request.

Generating documentation is just as simple. Run the commands below to create a new set of docs with chxdoc. The first command is optional if you already have chxdoc installed.

```bash
haxelib install chxdoc
ant doc
```

## Questions?

Drop by the [HaxePunk forum](http://forum.haxepunk.com) to ask anything or send me an email, heardtheword (at) gmail (dot) com.
