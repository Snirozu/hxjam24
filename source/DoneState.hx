class DoneState extends FlxState {
	var img:FlxSprite;

	override function create() {
		super.create();

		img = new FlxSprite(0, 0, AssetPaths.dun__png);
		img.alpha = 0;
		add(img);

		FlxG.sound.playMusic(AssetPaths.udun__ogg);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		img.alpha += elapsed / 3;

		if (FlxG.keys.justPressed.ENTER) {
			FlxG.sound.music.destroy();
			FlxG.switchState(new PlayState());
		}
	}
}
