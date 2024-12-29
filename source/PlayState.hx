class PlayState extends FlxState {
	public var player:Player;

	var fishes:FlxTypedGroup<Fish>;
	var bubbles:FlxTypedGroup<FlxSprite>;
	var scoreText:FlxBitmapText;
	var healthText:FlxBitmapText;
	var timeText:FlxBitmapText;
	var quotaText:FlxBitmapText;

	var upTip:FlxSprite;
	var depthMask:FlxSprite;
	var hook:FlxSprite;
	var hookRope:FlxSprite;

	public static var level:Int = 0;
	public static var sumScore:Float = 0;

	public var quota:Float = 500;
	public var score(default, set):Int = 0;
	public var health(default, set):Float = 100;

	var quotaComplete:Bool = false;

	var timeRemaining:Float = 120;
	var _prevTime:Int = 0;
	var _ceilTime:Int = 0;

	// sounds
	var lowHealth:FlxSound;
	var pickup:FlxSound;
	var explosion:FlxSound;
	var charge:FlxSound;
	var shoot:FlxSound;
	var wakeup:FlxSound;
	var complete:FlxSound;
	var hurtSounds:Array<FlxSound> = [];

	public function new(level:Int = 0) {
		super();

		if (level == 0) {
			Player.money = 0;
			PlayState.sumScore = 0;
			Player.items = [];
		}
		PlayState.level = level;
		quota = Math.min(500 + level * 500, 30000);

		#if CHEAT
		Player.items = Type.allEnums(Item);
		#end
	}

	override public function create() {
		super.create();

		persistentUpdate = false;

		var floors = 20;
		for (i in 0...floors) {
			var bg = new FlxSprite(0, FlxG.height * i);
			bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGBFloat(0, 0.1, (floors - i) / floors));
			add(bg);
		}

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height * floors);
		camera.setScrollBoundsRect(FlxG.worldBounds.x, FlxG.worldBounds.y - 16, FlxG.worldBounds.width, FlxG.worldBounds.height);

		player = new Player();
		camera.follow(player);
		add(player);

		player.y = -player.height;
		player.x = FlxG.worldBounds.width / 2 - player.width / 2;
		player.velocity.y = 300;

		hookRope = new FlxSprite();
		hookRope.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
		hookRope.scrollFactor.set(0, 0);
		add(hookRope);

		hook = new FlxSprite(0, 0, AssetPaths.hook__png);
		hook.visible = false;
		hook.drag.set(300, 300);
		add(hook);

		fishes = new FlxTypedGroup<Fish>();
		add(fishes);

		bubbles = new FlxTypedGroup<FlxSprite>();
		add(bubbles);

		depthMask = new FlxSprite(0, 0, AssetPaths.lampmask__png);
		if (!Player.items.contains(LAMP_OIL))
			depthMask.makeGraphic(depthMask.frameWidth, depthMask.frameHeight, FlxColor.BLACK);
		add(depthMask);

		var uiBg = new FlxSprite();
		uiBg.makeGraphic(FlxG.width, 16, FlxColor.BLACK);
		uiBg.scrollFactor.set(0, 0);
		add(uiBg);

		scoreText = new FlxBitmapText(0, 8, 'SCORE: ' + score, Util.getPixelFont());
		scoreText.scrollFactor.set(0, 0);
		add(scoreText);

		quotaText = new FlxBitmapText(0, 8, 'QUOTA: ' + quota, Util.getPixelFont());
		quotaText.scrollFactor.set(0, 0);
		quotaText.x = FlxG.width - quotaText.width;
		add(quotaText);

		healthText = new FlxBitmapText(0, 0, 'HEALTH: ' + health, Util.getPixelFont());
		healthText.scrollFactor.set(0, 0);
		add(healthText);

		timeText = new FlxBitmapText(0, 0, 'TIME: ' + timeRemaining, Util.getPixelFont());
		timeText.scrollFactor.set(0, 0);
		timeText.x = FlxG.width - timeText.width;
		add(timeText);

		upTip = new FlxSprite(0, 16, AssetPaths.tip_arrow__png);
		upTip.scrollFactor.set(0, 0);
		upTip.screenCenter(X);
		upTip.visible = false;
		add(upTip);

		lowHealth = FlxG.sound.load('assets/sounds/tightspot.ogg');
		hurtSounds.push(FlxG.sound.load('assets/sounds/hurt0.ogg'));
		hurtSounds.push(FlxG.sound.load('assets/sounds/hurt1.ogg'));
		hurtSounds.push(FlxG.sound.load('assets/sounds/hurt2.ogg'));
		pickup = FlxG.sound.load('assets/sounds/pickup.ogg');
		explosion = FlxG.sound.load('assets/sounds/explosion.ogg');
		charge = FlxG.sound.load('assets/sounds/charge.ogg');
		charge.volume = 0.5;
		shoot = FlxG.sound.load('assets/sounds/shooo.ogg');
		wakeup = FlxG.sound.load('assets/sounds/wakeup.ogg');
		complete = FlxG.sound.load('assets/sounds/complete.ogg');

		openSubState(new MessageSubSate('LEVEL ' + (level + 1)));
	}

	var fishSpawnDelay:Float = 0;
	var bombTimeout:Float = 0;
	var throwTimeout:Float = 0;
	var throwHold:Float = 0;
	var isThrowing:Bool = false;

	override public function update(elapsed:Float) {
		super.update(elapsed);

		if (player.y <= 0 && player.velocity.y < 0) {
			if (quotaComplete) {
				sumScore += score;
				var share = Math.ceil(Math.min((score - quota) / 100, (level + 1) * 15));
				Player.money += share;

				Player.items.remove(BOMBS);
				Player.items.remove(LAMP_OIL);

				openSubState(new MessageSubSate('SCORE: ' + score + '\nEARNED: ' + share + "$\nBALANCE: " + Player.money
					+ "$\n\nV TO VISIT THE SHOP\nENTER TO CONTINUE",
					() -> FlxG.switchState(new PlayState(level + 1)), _ -> {
						if (FlxG.keys.justPressed.V) {
							FlxG.switchState(new Shop());
						}
					}));
			}
			else {
				openSubState(new MessageSubSate('SCORE QUOTA\nNOT FULFILLED\n\nENTER TO CONTINUE\nESC TO QUIT', () -> {
					player.velocity.y = 200;
				}, _ -> {
					if (FlxG.keys.justPressed.ESCAPE) {
						FlxG.switchState(new DoneState());
					}
				}));
			}
		}

		timeRemaining -= elapsed;
		if (timeRemaining <= 0) {
			timeRemaining = 0;
			health = 0;
		}

		if (bombTimeout > 0)
			bombTimeout -= elapsed;

		if (throwTimeout > 0)
			throwTimeout -= elapsed;

		if (!FlxFlicker.isFlickering(timeText) && timeRemaining <= 30 && timeRemaining > 0) {
			FlxFlicker.flicker(timeText, 0, 0.5);
		}

		_ceilTime = Math.ceil(timeRemaining);
		if (_ceilTime != _prevTime) {
			timeText.text = 'TIME: ' + _ceilTime;

			if (_ceilTime <= 30 || _ceilTime % 2 == 0) {
				var bubble = new FlxSprite(player.x + player.width / 2 - 2, player.y + player.height / 4, AssetPaths.bubble__png);
				bubbles.add(bubble);
			}

			if (_ceilTime <= 40) {
				wakeup.play(true);
			}

			if (_ceilTime == 60 || _ceilTime == 40) {
				lowHealth.play(true).pitch = 0.6;
				FlxFlicker.flicker(timeText, 2, 0.25);
			}

			if (_ceilTime == 0) {
				timeText.text = 'TIMEOUT';
				timeText.x = FlxG.width - timeText.width;
				FlxFlicker.stopFlickering(timeText);
			}
		}
		_prevTime = _ceilTime;

		moveCheck(elapsed);

		if (FlxG.keys.justPressed.E && Player.items.contains(BOMBS) && bombTimeout <= 0) {
			bombTimeout = 5;
			explosion.play();
			for (fish in fishes) {
				if (Math.abs(player.x - fish.x) < 48 && Math.abs(player.y - fish.y) < 48) {
					touchFish(fish, true);
				}
			}
		}

		if (FlxG.mouse.justPressed && Player.items.contains(HOOK) && throwTimeout <= 0) {
			isThrowing = true;
			throwHold = 0;

			charge.play();
			charge.onComplete = () -> {
				isThrowing = false;
				player.skipAnim();
			};
		}
		if (isThrowing) {
			throwHold += elapsed;
			player.angle = FlxG.mouse.getWorldPosition().degreesFrom(player.getMidpoint());
			player.flipY = player.angle >= 90 || player.angle <= -90;
			player.flipX = false;
			player.playAnim('aim', 20);

			if (FlxG.mouse.justReleased) {
				throwTimeout = 20;
				isThrowing = false;
				hook.visible = true;
				hook.setPosition(player.x + player.width / 2 - hook.width / 2, player.y + player.height / 2 - hook.height / 2);
				hook.angle = FlxG.mouse.getWorldPosition().degreesFrom(hook.getMidpoint()) + 90;
				hook.velocity.set(0, 0);
				charge.stop();
				FlxVelocity.moveTowardsMouse(hook, Math.max(150, Math.min(throwHold * 300, 350)));
				shoot.play(true);
			}
		}
		else {
			player.flipY = false;
			player.angle = 0;

			if (hook.visible) {
				if (hook.velocity.x == 0 && hook.velocity.y == 0) {
					hook.velocity.set(0, 0);
					hook.x = FlxMath.lerp(hook.x, player.x + player.width / 2, elapsed * 10);
					hook.y = FlxMath.lerp(hook.y, player.y + player.height / 2, elapsed * 10);

					if (hook.overlaps(player)) {
						throwTimeout = 1;
						hook.visible = false;
						player.playAnim('pickup', 0.5);
					}
				}
			}
			else if (player.animation.name == 'aim') {
				player.skipAnim();
			}
		}

		hookRope.visible = hook.visible;
		if (hookRope.visible) {
			FlxSpriteUtil.fill(hookRope, FlxColor.TRANSPARENT);

			var playerScreen = player.getScreenPosition();
			var hookScreen = hook.getScreenPosition();
			// blame haxe's amazing formatter not me
			FlxSpriteUtil.drawLine(hookRope, playerScreen.x
				+ player.width / 2, playerScreen.y
				+ player.height / 2, hookScreen.x
				+ hook.width / 2,
				hookScreen.y
				+ hook.height / 2, {
					thickness: 3,
					color: FlxColor.BLACK,
					pixelHinting: false
				}, {
					smoothing: false
				});
		}

		for (bubble in bubbles) {
			bubble.x += (FlxG.random.bool() ? Math.sin(timeRemaining) : Math.cos(timeRemaining)) * 0.4;
			bubble.y -= elapsed * 100;

			if (bubble.y < 0) {
				bubble.destroy();
				bubbles.remove(bubble);
			}
		}

		for (fish in fishes) {
			if (!fish.exists) {
				fishes.remove(fish);
				continue;
			}

			if (hook.visible && hook.overlaps(fish)) {
				touchFish(fish, true);
				continue;
			}

			if (player.overlaps(fish) && !FlxFlicker.isFlickering(player)) {
				touchFish(fish);
			}
		}

		fishSpawnDelay -= Math.min(player.y / FlxG.height, 10) * 0.01;

		// maybe change later to random interval?
		if (fishSpawnDelay <= 0) {
			fishes.add(new Fish(FlxG.random.float(camera.viewY - FlxG.height * 2.5, camera.viewY + FlxG.height * 2.5)));
			fishSpawnDelay = FlxG.random.float(0.4, 0.8);
		}

		depthMask.setPosition(player.x + player.width / 2 - depthMask.width / 2, player.y + player.height / 2 - depthMask.height / 2);
		depthMask.alpha = (player.y / FlxG.height - 5) / 3;

		if (FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.ENTER) {
			openSubState(new PauseMenu());
		}
	}

	// freaky function
	function touchFish(fish:Fish, ?isItem:Bool = false) {
		var addScore = 0;
		switch (fish.type) {
			case 0:
				addScore = 50;
			case 1:
				if (!isItem) {
					addScore = -50;
					health -= 10;
				}
				else {
					addScore = 100;
				}
			case 2:
				addScore = 250;
			// health -= 5;
			case 3:
				addScore = 350;
		}
		score += addScore;
		showScore(addScore, fish);
		fish.destroy();
	}

	function showScore(score:Float, ?object:FlxSprite) {
		if (object == null) {
			object = player;
		}

		var scoreNum = new FlxBitmapText(0, 0, score + '');
		scoreNum.x = object.x + object.width / 2 - scoreNum.width / 2;
		scoreNum.y = object.y + object.height / 2 - scoreNum.height / 2;
		add(scoreNum);

		FlxTween.tween(scoreNum, {y: scoreNum.y - 16}, 0.5);
		FlxTween.tween(scoreNum, {alpha: 0}, 1, {
			onComplete: _ -> {
				scoreNum.destroy();
				remove(scoreNum);
			}
		});
	}

	function showHealth(health:Float) {
		var healthNum = new FlxBitmapText(0, 0, health + '');
		healthNum.x = player.x + player.width / 2 - healthNum.width / 2;
		healthNum.y = player.y + player.height / 2 - healthNum.height / 2;
		healthNum.color = FlxColor.RED;
		add(healthNum);
		FlxTween.tween(healthNum, {y: healthNum.y - 16, x: healthNum.x - 16, alpha: 0}, 1, {
			onComplete: _ -> {
				healthNum.destroy();
				remove(healthNum);
			}
		});
	}

	override function onFocusLost() {
		super.onFocusLost();

		if (subState != null)
			return;

		openSubState(new PauseMenu());
	}

	var spaceTime:Float = 0;

	function moveCheck(elapsed:Float) {
		var walkSpeed = FlxG.keys.pressed.SHIFT && Player.items.contains(FINS) ? 1.5 : 1;

		var playAnim = 'idle';

		if (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.A) {
			player.velocity.x -= walkSpeed;
			player.flipX = true;
			playAnim = "dive";
		}
		if (FlxG.keys.pressed.RIGHT || FlxG.keys.pressed.D) {
			player.velocity.x += walkSpeed;
			player.flipX = false;
			playAnim = "dive";
		}

		if (FlxG.keys.pressed.UP || FlxG.keys.pressed.SPACE || FlxG.keys.pressed.W) {
			if (spaceTime <= 0) {
				player.velocity.y -= 100;
				spaceTime = 0.25 / walkSpeed;
			}
			playAnim = "dive";
		}
		if (FlxG.keys.pressed.DOWN || FlxG.keys.pressed.S) {
			player.velocity.y += walkSpeed * 2;
			playAnim = "divedown";
		}

		player.playAnim(playAnim);

		player.velocity.x = FlxMath.lerp(player.velocity.x, 0, 2 * elapsed);
		player.velocity.y = FlxMath.lerp(player.velocity.y, 0, 5 * elapsed);

		spaceTime -= elapsed;
	}

	var hasMaxProfit:Bool = false;

	function set_score(v:Int) {
		if (v > score) {
			pickup.play(true);
			player.playAnim('pickup', 0.5);
		}

		if (score < quota && v >= quota) {
			quotaComplete = true;
			quotaText.text = 'FULFILLED!';
			quotaText.x = FlxG.width - quotaText.width;
			FlxFlicker.flicker(quotaText, 0.5, 0.05);
			player.playAnim('yay', 1);
			complete.play(true).pitch = 0.85;

			FlxFlicker.flicker(upTip, 0, 0.5);
		}

		if (quotaComplete) {
			var percent = Util.percentOf(Math.ceil((score - quota) / 100), (level + 1) * 15);
			scoreText.text = 'PROFIT: ' + percent + "%";

			if (!hasMaxProfit && percent >= 100) {
				hasMaxProfit = true;
				FlxFlicker.flicker(scoreText, 0.5, 0.05);
				player.playAnim('yay', 1.5);
				complete.play(true).pitch = 1;
			}
		}
		else
			scoreText.text = 'SCORE: ' + v;
		return score = v;
	}

	function set_health(v:Float) {
		if (v <= 0) {
			v = 0;
			sumScore += score;
			openSubState(new GameOver(this));
		}

		showHealth(v - health);
		lowHealth.volume = 1;
		player.playAnim('hurt', 1);
		FlxFlicker.flicker(player, 0.5, 0.1);
		FlxTween.shake(player, 0.1, 0.5, X);

		if (v < health) {
			FlxG.random.getObject(hurtSounds).play(true);
		}

		if (v <= 20 && !FlxFlicker.isFlickering(healthText))
			FlxFlicker.flicker(healthText, 0, 1, true, true, null, _ -> {
				if (subState != null)
					return;

				lowHealth.play(true).pitch = 1.0;
				lowHealth.volume -= 0.1;
				if (lowHealth.volume < 0.1) {
					lowHealth.volume = 0.1;
				}
			});
		else if (v >= 20)
			FlxFlicker.stopFlickering(healthText);

		healthText.text = 'HEALTH: ' + Math.ceil(v);
		return health = v;
	}
}
