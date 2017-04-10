package haxepunk.ds;

import haxe.ds.Either;

@:dox(hide)
abstract OneOf<L, R>(Either<L, R>) from Either<L, R> to Either<L, R>
{
	@:from public static function fromL<L, R>(val:L):OneOf<L, R> return Left(val);
	@:from public static function fromR<L, R>(val:R):OneOf<L, R> return Right(val);

	@:to inline function toL():Null<L> return switch(this) {case Left(val): val; default: null;}
	@:to inline function toR():Null<R> return switch(this) {case Right(val): val; default: null;}
}
