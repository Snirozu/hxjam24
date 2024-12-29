class GameOver extends FlxSubState {
	var skull:FlxSprite;
	var text:FlxBitmapText;

	public function new(game:PlayState) {
		super();

		FlxG.sound.play(AssetPaths.hit__ogg);

		var bg = new FlxSprite();
		bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.scrollFactor.set(0, 0);
		add(bg);

		skull = new FlxSprite(game.player.getScreenPosition().x, game.player.getScreenPosition().y, AssetPaths.death__png);
		skull.scrollFactor.set(0, 0);
		add(skull);

		var gameOverTxt = "GAME OVER";
		if (FlxG.random.bool(0.01)) {
			gameOverTxt = "BALLS OVER";
		}

		text = new FlxBitmapText(0, 0,
			gameOverTxt
			+ '\n'
			+ "\nSTATISTICS\n\n"
			+ "SCORE: "
			+ PlayState.sumScore
			+ "\n"
			+ "LEVEL: "
			+ (PlayState.level + 1)
			+ "\n\n\nPRESS ENTER\nTO CONTINUE",
			Util.getPixelFont());
		text.alignment = CENTER;
		text.scrollFactor.set(0, 0);
		text.screenCenter(XY);
		text.y += 8;
		text.alpha = 0;
		add(text);
	}

	var textVisible:Bool = false;
	var delay:Float = 1;

	override function update(elapsed) {
		super.update(elapsed);

		if (delay > 0) {
			delay -= elapsed;
			return;
		}

		skull.setPosition(FlxMath.lerp(skull.x, FlxG.width / 2 - skull.width / 2, elapsed * 2), FlxMath.lerp(skull.y, text.y - skull.height - 16, elapsed * 2));

		if (!textVisible && skull.x <= FlxG.width / 2 - skull.width / 2 + 1 && skull.y <= text.y - skull.height - 16 + 1) {
			textVisible = true;
		}

		if (textVisible && text.alpha < 1) {
			text.alpha += elapsed * 2;
		}

		if (text.alpha >= 1 && FlxG.keys.justPressed.ENTER) {
			FlxG.switchState(() -> new PlayState());
		}
	}
}
