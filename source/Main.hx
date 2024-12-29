class Main extends Sprite {
	public function new() {
		super();

		addChild(new FlxGame(192, 174, PlayState, 120, 120));
		#if html5
		addChild(new openfl.display.Bitmap(new openfl.display.BitmapData(openfl.Lib.application.window.width, 1, false, FlxColor.BLACK)));
		#end
	}
}
