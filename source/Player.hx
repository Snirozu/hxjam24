class Player extends FlxSprite {
	public static var money:Float = 0;

	var _animFPS = 3;

	public var stunned:Bool = false;

	public static var items:Array<Item> = [];

	public function new() {
		super();

		loadGraphic(AssetPaths.player__png, true, 16, 17);
		animation.add("idle", [0], _animFPS, true);
		animation.add("hurt", [2], _animFPS, false);
		animation.add("aim", [3], _animFPS, false);
		animation.add("yay", [4], _animFPS, false);
		animation.add("pickup", [5], _animFPS, false);
		animation.add("divedown", [6, 7], _animFPS, true);
		animation.add("dive", [1, 0], _animFPS, true);
		playAnim("idle");

		maxVelocity.set(2000, 2000);
		acceleration.y = 100;
	}

	var animTime:Float = 0;
	var nextAnim:String = '';

	public function playAnim(name:String, animTime:Float = 0) {
		if (animTime <= 0 && this.animTime > 0) {
			nextAnim = name;
			return;
		}

		nextAnim = null;
		this.animTime = animTime;
		animation.play(name);
	}

	public function skipAnim() {
		playAnim(nextAnim);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (animTime > 0) {
			animTime -= elapsed;

			if (animTime <= 0) {
				skipAnim();
			}
		}

		if (y + height >= FlxG.worldBounds.height)
			y = FlxG.worldBounds.height - height;
		if (x <= 0)
			x = 0;
		if (x + width >= FlxG.worldBounds.width)
			x = FlxG.worldBounds.width - width;
	}
}

enum Item {
	LAMP;
	HOOK;
	BOMBS;
	LAMP_OIL;
	FINS;
	// LURE
}
