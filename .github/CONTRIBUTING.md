# Contributing to HaxePunk

There are a few ways you can contribute to this project. The first is to simply create an issue clearly defining the problem you are having and any examples that might help us recreate it. The second is to fork the project, make changes, and submit a pull request following the guidelines listed below.

## Making a Pull Request

Follow the steps below to make changes and submit a pull request.

* Create a local branch using `git checkout -b <my branch name>`
  * Not required but will allow you to submit multiple changes and leaves the master branch untouched
* Make changes and test
* Commit the changes to your new branch
* Push to your repository `git push origin <my branch name>`
* Create a pull request and point it to the appropriate branch for HaxePunk

## Git Branches and Tagging

HaxePunk uses multiple branches for development and each one has a specific purpose. Here is an overview of each branch type.

<dl>
	<dt>master</dt>
	<dd>Reflects the last stable release to haxelib</dd>
	<dt>dev</dt>
	<dd>The bleeding edge branch. This will always contain the most recent and volatile changes.</dd>
	<dt>release-x.x.x</dt>
	<dd>This is a release branch which contains the features scheduled for a specific release on haxelib.</dd>
	<dt>feature-*</dt>
	<dd>This is a feature branch. It will contain code specific to a feature in development or that needs additional testing/approval.</dd>
</dl>

When each release is merged into the master branch it is tagged as a version (v2.5.2 for example). This allows anyone to download past versions of HaxePunk.

## Testing HaxePunk

It is suggested that you test your changes on Flash and Neko if making updates to cross-platform code. There are unit tests that can be run by typing `ant unit` on the command line. It's also good to run the full suite, with examples, by typing `ant`. This may require you to install [Ant](http://ant.apache.org/) unless you already have it on your computer.

## Programming Guidlines

_The following are guidlines on how to format the code you submit to HaxePunk. In the end just use good judgement and try to match the styling of the other classes._

A space should be placed after `if`, `for`, `while`, and `switch`. No space before or after the parentheses. Statements within blocks should be indented using a tab.

```haxe
for (item in list)
{
	item.handle();
}
```

Curly braces should be on their own line. This is to improve visual scanning of a document.

```haxe
// GOOD
if (testCondition)
{
	doSomething();
}
else
{
	doSomethingElse();
}

// GOOD
class MyClass extends AnotherClass
{
	public function new()
	{
		super();
	}
}

// BAD
if (performCheck(first,
	second,
	third)) {
	foo();
} else {
	bar();
}
```

Put spaces between operators and after commas. It makes code easier to scan.

```haxe
// GOOD
var x = 10 + (52 / m) - z.q;

// GOOD
function (a:Int, b:Float, c:String)
{
}

// BAD
var x=10+(52/m)-z.q;

// BAD
function (a:Int,b:Float,c:String)
{
}
```

Types only need to be included on variables that are not explicitly defined in a statement. Multiple vars may be created by connecting them with commas.

```haxe
// GOOD
var a = new Array<String>(),
	str = "my string";
var i:Int = 0;
var foo:Array<Dynamic> = [1, "hi", b];

// BAD
var i = 0; // float or int?
var a = new Array<String>(), str = "my string", other:Int = 39, i, j, k; // split into multiple lines
```

Function declarations should always include the parameter types. Public functions should return `Void` if not returning a value and should have doc styled comments. Optional arguments should use a `?` if expected to be null or `=` if assigning a value.

```haxe
/**
 * My class
 */
class MyClass
{
	/**
	 * A function to do things
	 * @param val1  The first value of this function
	 * @param val2  This can be set to null
	 * @param val3  This value defaults to 1
	 */
	public function doThings(val1:Int, ?val2:String, val3:Int=1):Void
	{
	}

	/**
	 * Returns an array
	 * @return An array of strings
	 */
	private function createArray():Array<String>
	{
	}
}
```

Put public variables at the top of your class and private variables at the bottom. This was a style brought from FlashPunk. The exception is properties which should be placed together with their getter/setter functions (which should be private).

```haxe
class MyClass
{
	public var index:Int = 0;

	public function new()
	{
	}

	@:isVar public var prop(get, set):Bool;
	private function get_prop():Bool { return prop; }
	private function set_prop(value:Bool):Bool
	{
		return prop = value;
	}

	private function doSomething():Int
	{
		return 0;
	}

	private var map:Map<String, Int>;
}
```

### Additional suggestions

<dl>
<dt>Please delete trailing whitespace on save</dt>
<dd>Most editors have this as an option. It makes commits less cluttered with whitespace changes.</dd>

<dt>Please document new functions and classes</dt>
<dd>This helps others understand how to use the added functionality. We may request that you add this before merging your pull request.</dd>
</dl>
