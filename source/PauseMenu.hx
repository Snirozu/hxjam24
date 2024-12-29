class PauseMenu extends FlxSubState {
	public function new() {
		super();

		var bg = new FlxSprite(0, 0, AssetPaths.pause__png);
		bg.scrollFactor.set(0, 0);
		add(bg);

		var text = new FlxBitmapText(0, 0, 'PAUSE', Util.getPixelFont());
		text.scrollFactor.set(0, 0);
		text.setPosition(FlxG.width - text.width - 16, FlxG.height - text.height - 16);
		add(text);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (FlxG.keys.justPressed.ENTER) {
			close();
		}

		if (FlxG.keys.justPressed.DELETE) {
			FlxG.switchState(new PlayState());
		}
	}
}
