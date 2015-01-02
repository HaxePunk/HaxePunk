package haxepunk2d;

/**
 * Represent a shape, can be used to create images or masks.
 */
interface Shape<T:Mask>
{
	/**
	 * Create an image from the shape.
	 */
	public function toImage(?config:ImageConfig):Image;
	
	/**
	 * Create a mask from the shape.
	 */
	public function toMask(?config:MaskConfig):T;
}
