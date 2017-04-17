package haxepunk.ds;

abstract Maybe<T>(Null<T>) from Null<T>
{

	public inline function exists():Bool return this != null;
	public inline function ensure():T return exists() ? this : throw "No value";
	public inline function or(defaultValue:T):T return exists() ? this : defaultValue;
	public inline function may(fn:T->Void):Void if (exists()) fn(this);
	public inline function map<S>(fn:T->S, defaultValue:S):S return exists() ? fn(this) : defaultValue;
	public inline function mapMaybe<S>(fn:T->S):Maybe<S> return exists() ? fn(this) : null;

}
