class MessageSubSate extends FlxSubState {
	var updateCallback:Float->Void = null;

	public function new(msg:String, ?closeCallback:Void->Void, ?updateCallback:Float->Void) {
		super();

		this.closeCallback = closeCallback;
		this.updateCallback = updateCallback;

		var bg = new FlxSprite(0, 0, AssetPaths.mask__png);
		bg.scrollFactor.set(0, 0);
		add(bg);

		var text = new FlxBitmapText(0, 0, msg, Util.getPixelFont());
		text.scrollFactor.set(0, 0);
		text.alignment = CENTER;
		text.screenCenter(XY);

		var bigBlackSquare = new FlxSprite();
		bigBlackSquare.scrollFactor.set(0, 0);
		bigBlackSquare.makeGraphic(Std.int(text.width) + 16 * 2, Std.int(text.height) + 16 * 2, FlxColor.BLACK);
		bigBlackSquare.screenCenter(XY);

		add(bigBlackSquare);
		add(text);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (updateCallback != null)
			updateCallback(elapsed);

		if (FlxG.keys.justPressed.ENTER) {
			close();
		}
	}
}
