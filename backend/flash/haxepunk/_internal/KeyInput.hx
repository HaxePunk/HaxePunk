package haxepunk._internal;

import flash.events.KeyboardEvent;
import haxepunk.input.Key;

class KeyInput
{
	public static function init(app:FlashApp)
	{
		var stage = app.stage;
		stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownCallback, false,  2);
		stage.addEventListener(KeyboardEvent.KEY_UP, keyUpCallback, false,  2);

		#if !(js)
		_nativeCorrection.set("0_64", Key.INSERT);
		_nativeCorrection.set("0_65", Key.END);
		_nativeCorrection.set("0_66", Key.DOWN);
		_nativeCorrection.set("0_67", Key.PAGE_DOWN);
		_nativeCorrection.set("0_68", Key.LEFT);
		_nativeCorrection.set("0_69", -1);
		_nativeCorrection.set("0_70", Key.RIGHT);
		_nativeCorrection.set("0_71", Key.HOME);
		_nativeCorrection.set("0_72", Key.UP);
		_nativeCorrection.set("0_73", Key.PAGE_UP);
		_nativeCorrection.set("0_266", Key.DELETE);
		_nativeCorrection.set("123_222", Key.LEFT_SQUARE_BRACKET);
		_nativeCorrection.set("125_187", Key.RIGHT_SQUARE_BRACKET);
		_nativeCorrection.set("126_233", Key.TILDE);

		_nativeCorrection.set("0_80", Key.F1);
		_nativeCorrection.set("0_81", Key.F2);
		_nativeCorrection.set("0_82", Key.F3);
		_nativeCorrection.set("0_83", Key.F4);
		_nativeCorrection.set("0_84", Key.F5);
		_nativeCorrection.set("0_85", Key.F6);
		_nativeCorrection.set("0_86", Key.F7);
		_nativeCorrection.set("0_87", Key.F8);
		_nativeCorrection.set("0_88", Key.F9);
		_nativeCorrection.set("0_89", Key.F10);
		_nativeCorrection.set("0_90", Key.F11);

		_nativeCorrection.set("48_224", Key.DIGIT_0);
		_nativeCorrection.set("49_38", Key.DIGIT_1);
		_nativeCorrection.set("50_233", Key.DIGIT_2);
		_nativeCorrection.set("51_34", Key.DIGIT_3);
		_nativeCorrection.set("52_222", Key.DIGIT_4);
		_nativeCorrection.set("53_40", Key.DIGIT_5);
		_nativeCorrection.set("54_189", Key.DIGIT_6);
		_nativeCorrection.set("55_232", Key.DIGIT_7);
		_nativeCorrection.set("56_95", Key.DIGIT_8);
		_nativeCorrection.set("57_231", Key.DIGIT_9);

		_nativeCorrection.set("48_64", Key.NUMPAD_0);
		_nativeCorrection.set("49_65", Key.NUMPAD_1);
		_nativeCorrection.set("50_66", Key.NUMPAD_2);
		_nativeCorrection.set("51_67", Key.NUMPAD_3);
		_nativeCorrection.set("52_68", Key.NUMPAD_4);
		_nativeCorrection.set("53_69", Key.NUMPAD_5);
		_nativeCorrection.set("54_70", Key.NUMPAD_6);
		_nativeCorrection.set("55_71", Key.NUMPAD_7);
		_nativeCorrection.set("56_72", Key.NUMPAD_8);
		_nativeCorrection.set("57_73", Key.NUMPAD_9);
		_nativeCorrection.set("42_268", Key.NUMPAD_MULTIPLY);
		_nativeCorrection.set("43_270", Key.NUMPAD_ADD);
		//_nativeCorrection.set("", Key.NUMPAD_ENTER);
		_nativeCorrection.set("45_269", Key.NUMPAD_SUBTRACT);
		_nativeCorrection.set("46_266", Key.NUMPAD_DECIMAL); // point
		_nativeCorrection.set("44_266", Key.NUMPAD_DECIMAL); // comma
		_nativeCorrection.set("47_267", Key.NUMPAD_DIVIDE);
		#end
	}

	static inline function keyCode(e:KeyboardEvent):Int
	{
	#if (js)
		return e.keyCode;
	#else
		var code = _nativeCorrection.get(e.charCode + "_" + e.keyCode);
		return code == null ? e.keyCode : code;
	#end
	}

	@:access(haxepunk.input.Key)
	static function keyDownCallback(?e:KeyboardEvent)
	{
		var code:Int = keyCode(e);
		if (code == -1) // No key
			return;
		Key.onKeyDown(code, e.shiftKey);
	}

	@:access(haxepunk.input.Key)
	static function keyUpCallback(?e:KeyboardEvent)
	{
		var code:Int = keyCode(e);
		if (code == -1) // No key
			return;
		Key.onKeyUp(code);
	}

	static var _nativeCorrection:Map<String, Int> = new Map<String, Int>();
}
