class Fish extends FlxSprite {
	public var type:Int = 0;
	public var speed:Float = 1;
	public var lifeTime:Float = 0;
	public var pathY:Float = 0;
	public var level:Float = 0;

	var behaviorType:Int = 0;
	var delay:Float = 0;

	public function new(y:Float = 0) {
		this.pathY = y;

		pathY = Math.abs(pathY);
		if (pathY <= 16 * 3)
			pathY += 16 * 3;

		level = pathY / FlxG.height;

		type = FlxG.random.weightedPick([
			50, // regular
			20, // pufferfish
			level * (level * 0.15), // jellyfish
			Math.max(0, level - 6) * 2 // clownfish
		]);

		super(0, pathY, 'assets/images/fish${type}.png');

		flipX = FlxG.random.bool();
		if (flipX)
			x = -width;
		else
			x = FlxG.width;

		speed = FlxG.random.float(1, 3);

		switch (type) {
			case 0, 1:
				behaviorType = 0;
			case 3:
				speed *= 2;
			case 2:
				behaviorType = 1;
				drag.set(50, 50);
				speed *= 3;
				angle = flipX ? 20 : -20;
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		lifeTime += elapsed;
		if (delay > 0)
			delay -= elapsed;

		switch (behaviorType) {
			case 0:
				y = pathY + Math.cos(lifeTime * speed) * 8;
				angle = Math.sin(lifeTime * speed);

				if (flipX) {
					x += 16 * elapsed * speed;
				}
				else {
					x -= 16 * elapsed * speed;
				}
			case 1:
				if (delay <= 0) {
					if (flipX)
						velocity.x = 50;
					else
						velocity.x = -50;
					velocity.y = -50;
					delay = 3 / speed;
				}

				y += elapsed * (8 + 2 * speed);
				scale.y = Math.max(-velocity.y / 40, 0.6);
				// y = FlxMath.lerp(y, pathY, 5 * elapsed);
		}

		if (!flipX && x < -width)
			destroy();
		if (flipX && x > FlxG.width)
			destroy();
	}
}
