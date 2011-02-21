package net.flashpunk.tweens.misc 
{
	import net.flashpunk.Tween;
	
	/**
	 * Tweens a color's red, green, and blue properties
	 * independently. Can also tween an alpha value.
	 */
	public class ColorTween extends Tween
	{
		/**
		 * The current color.
		 */
		public var color:uint;
		
		/**
		 * The current alpha.
		 */
		public var alpha:Number = 1;
		
		/**
		 * Constructor.
		 * @param	complete	Optional completion callback.
		 * @param	type		Tween type.
		 */
		public function ColorTween(complete:Function = null, type:uint = 0) 
		{
			super(0, type, complete);
		}
		
		/**
		 * Tweens the color to a new color and an alpha to a new alpha.
		 * @param	duration		Duration of the tween.
		 * @param	fromColor		Start color.
		 * @param	toColor			End color.
		 * @param	fromAlpha		Start alpha
		 * @param	toAlpha			End alpha.
		 * @param	ease			Optional easer function.
		 */
		public function tween(duration:Number, fromColor:uint, toColor:uint, fromAlpha:Number = 1, toAlpha:Number = 1, ease:Function = null):void
		{
			fromColor &= 0xFFFFFF;
			toColor &= 0xFFFFFF;
			color = fromColor;
			_r = fromColor >> 16 & 0xFF;
			_g = fromColor >> 8 & 0xFF;
			_b = fromColor & 0xFF;
			_startR = _r / 255;
			_startG = _g / 255;
			_startB = _b / 255;
			_rangeR = ((toColor >> 16 & 0xFF) / 255) - _startR;
			_rangeG = ((toColor >> 8 & 0xFF) / 255) - _startG;
			_rangeB = ((toColor & 0xFF) / 255) - _startB;
			_startA = alpha = fromAlpha;
			_rangeA = toAlpha - alpha;
			_target = duration;
			_ease = ease;
			start();
		}
		
		/** @private Updates the Tween. */
		override public function update():void 
		{
			super.update();
			alpha = _startA + _rangeA * _t;
			_r = uint((_startR + _rangeR * _t) * 255);
			_g = uint((_startG + _rangeG * _t) * 255);
			_b = uint((_startB + _rangeB * _t) * 255);
			color = _r << 16 | _g << 8 | _b;
		}
		
		/**
		 * Red value of the current color, from 0 to 255.
		 */
		public function get red():uint { return _r; }
		
		/**
		 * Green value of the current color, from 0 to 255.
		 */
		public function get green():uint { return _g; }
		
		/**
		 * Blue value of the current color, from 0 to 255.
		 */
		public function get blue():uint { return _b; }
		
		// Color information.
		/** @private */ private var _r:uint;
		/** @private */ private var _g:uint;
		/** @private */ private var _b:uint;
		/** @private */ private var _startA:Number;
		/** @private */ private var _startR:Number;
		/** @private */ private var _startG:Number;
		/** @private */ private var _startB:Number;
		/** @private */ private var _rangeA:Number;
		/** @private */ private var _rangeR:Number;
		/** @private */ private var _rangeG:Number;
		/** @private */ private var _rangeB:Number;
	}
}