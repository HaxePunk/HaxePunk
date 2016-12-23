package haxepunk.ds;

@:dox(hide)
enum Either<L, R>
{
	Left( v:L );
	Right( v:R );
}
