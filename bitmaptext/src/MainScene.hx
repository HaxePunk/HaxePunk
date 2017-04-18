import haxepunk.HXP;
import haxepunk.Entity;
import haxepunk.Scene;
import haxepunk.graphics.BitmapText;
import haxepunk.graphics.Image;

class MainScene extends Scene
{
	public function new()
	{
		super();

		BitmapText.defineFormatTag("blue", 0x5f8dd3);
		BitmapText.defineFormatTag("ghost", null, 0.5);
		BitmapText.defineFormatTag("big", null, null, 1.5);
		BitmapText.defineFormatTag("big_green", 0x55d400, null, 1.5);
		var img = new Image("assets/graphics/star.png");
		img.scale = 0.25;
		img.smooth = true;
		BitmapText.defineImageTag("star", img);
		var img = new Image("assets/graphics/star.png");
		img.scale = 0.5;
		img.smooth = true;
		BitmapText.defineImageTag("big-star", img);

		var txt = new BitmapText("Here's some colored text.", 0, 0, 0, 0, {
			font: "assets/fonts/azmoonfleet.64.fnt",
			size: 14,
			color: 0xff0000,
		});
		addText(txt);

		var txt = new BitmapText("Char\nand line spacing", 0, 0, 0, 0, {
			font: "assets/fonts/azmoonfleet.64.fnt",
			size: 14,
		});
		txt.charSpacing = txt.lineSpacing = 16;
		addText(txt);

		var txt = new BitmapText("This is some wrapped text. It will fill as much vertical space as needed, but width is limited, so it shouldn't extend past 75% of the screen width. This whole paragraph should wrap correctly.\nHard line breaks are also allowed.", 0, 0, Std.int(HXP.width * 0.75), 0, {
			font: "assets/fonts/azmoonfleet.64.fnt",
			size: 14,
			color: 0x00ff00,
			wordWrap: true
		});
		addText(txt);

		var txt = new BitmapText("This is <big>some</big> <blue><big>formatted</big> text.</blue> It should also <big_green>wrap</big_green> so it doesn't go past 75% of the screen width. <big>Big</big> and small text should start from the bottom of the line.", 0, 0, Std.int(HXP.width * 0.75), 0, {
			font: "assets/fonts/azmoonfleet.64.fnt",
			size: 14,
			wordWrap: true
		});
		addText(txt);

		var txt = new BitmapText("You can even <blue>include inline images</blue> in your <star/><big-star/>text<big-star/><star/>!", 0, 0, Std.int(HXP.width * 0.75), 0, {
			font: "assets/fonts/azmoonfleet.64.fnt",
			size: 14,
			wordWrap: true
		});
		addText(txt);

		var txt = new BitmapText("Text can be <big>scaled</big> in <star/>any<star/> direction.", 0, 0, Std.int(HXP.width * 0.75), 0, {
			font: "assets/fonts/azmoonfleet.64.fnt",
			size: 14,
			wordWrap: true
		});
		txt.scaleX = 1.5;
		txt.scaleY = 0.75;
		addText(txt);

		gradualText = new BitmapText("The <big_green>displayCharCount</big_green> field can be used to gradually display or <ghost>hide</ghost> text <star/>and images<star/>.\n\nIt supports line breaks and <blue>markup tags</blue> too, and always breaks words correctly instead of rendering the first few characters on one line then jumping down to the next.", 0, 0, Std.int(HXP.width * 0.75), 0, {
			font: "assets/fonts/azmoonfleet.64.fnt",
			size: 14,
			wordWrap: true
		});
		gradualText.lineSpacing = 8;
		gradualText.displayCharCount = 0;
		addText(gradualText);

		var txt = new BitmapText("<center>Also, here is some centered</center><right>or right-aligned text!\nIt also supports line breaks and wrapping, of course.</right>", 0, 0, Std.int(HXP.width * 0.75), 0, {
			font: "assets/fonts/azmoonfleet.64.fnt",
			size: 14,
			wordWrap: true
		});
		addText(txt);
	}

	function addText(txt:BitmapText)
	{
		var entity = new Entity(txt);
		entity.width = Std.int(txt.textWidth * txt.scale * txt.scaleX);
		entity.height = Std.int(txt.textHeight * txt.scale * txt.scaleY);
		entity.y = _y;
		_y += txt.textHeight + 4;
		add(entity);
	}

	override public function update()
	{
		super.update();
		t += HXP.elapsed * 24 * tDirection;
		gradualText.displayCharCount = Std.int(t);
		if (t > gradualText.text.length) tDirection = -1;
		else if (t < 0) tDirection = 1;
	}

	var gradualText:BitmapText;
	var _y:Float = 0;
	var t:Float = 0;
	var tDirection:Int = 1;
}
