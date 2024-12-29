class Shop extends FlxState {
	var items:FlxTypedGroup<FlxBitmapText>;
	var curSelected:Int = 0;

	var balance:FlxBitmapText;
	var quit:FlxBitmapText;

	static var itemPriceMap:Map<Item, Int> = [LAMP => 50, HOOK => 250, BOMBS => 50, LAMP_OIL => 25, FINS => 500];

	var indexItems:Array<Item>;

	var buySound:FlxSound;
	var errSound:FlxSound;

	override function create() {
		super.create();

		var title = new FlxBitmapText(0, 16, "- SHOP -", Util.getPixelFont());
		title.screenCenter(X);
		add(title);

		balance = new FlxBitmapText(0, 32, "BALANCE: " + Player.money + "$", Util.getPixelFont());
		balance.screenCenter(X);
		add(balance);

		add(items = new FlxTypedGroup());

		for (i => item in [
			Item.BOMBS,
			Item.HOOK,
			(Player.items.contains(Item.LAMP) ? Item.LAMP_OIL : Item.LAMP),
			Item.FINS
		]) {
			var itemOption = new FlxBitmapText(0, 64 + i * 16, '', Util.getPixelFont());
			itemOption.screenCenter(X);
			itemOption.ID = item.getIndex();
			items.add(itemOption);
		}

		updateItems();

		quit = new FlxBitmapText(0, items.members[items.length - 1].y + 32, "Q FOR ITEM INFO\nESC TO LEAVE", Util.getPixelFont());
		quit.screenCenter(X);
		quit.alignment = CENTER;
		add(quit);

		buySound = FlxG.sound.load('assets/sounds/usm.ogg');
		errSound = FlxG.sound.load('assets/sounds/esm.ogg');

		indexItems = Type.allEnums(Item);
	}

	function updateItems() {
		var daItems:Array<Item> = Type.allEnums(Item);

		for (item in items) {
			if (Player.items.contains(daItems[item.ID])) {
				item.text = daItems[item.ID].getName().replace('_', ' ') + " - SOLD OUT";
			}
			else {
				item.text = daItems[item.ID].getName().replace('_', ' ') + " - " + itemPriceMap.get(daItems[item.ID]) + "$";
			}
			item.screenCenter(X);
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.UP)
			curSelected--;
		if (FlxG.keys.justPressed.S || FlxG.keys.justPressed.DOWN)
			curSelected++;

		if (curSelected < 0)
			curSelected = items.length - 1;
		if (curSelected > items.length - 1)
			curSelected = 0;

		for (i => item in items) {
			item.alpha = 0.6;
			if (i == curSelected) {
				item.alpha = 1;

				if (FlxG.keys.justPressed.ENTER) {
					if (Player.items.contains(indexItems[item.ID])) {
						openSubState(new MessageSubSate('YOU ALREADY HAVE\nTHIS ITEM!'));
						errSound.play(true);
						return;
					}

					if (Player.money >= itemPriceMap.get(indexItems[item.ID])) {
						Player.money -= itemPriceMap.get(indexItems[item.ID]);

						Player.items.push(indexItems[item.ID]);
						if (indexItems[item.ID] == LAMP) {
							Player.items.push(LAMP_OIL);
						}

						balance.text = "BALANCE: " + Player.money + "$";
						updateItems();
						buySound.play(true);
					}
					else {
						openSubState(new MessageSubSate('NOT ENOUGH\nMONEY!'));
						errSound.play(true);
					}
				}
				if (FlxG.keys.justPressed.Q) {
					switch (indexItems[item.ID]) {
						case HOOK:
							openSubState(new MessageSubSate('- HOOK -\nThrowable item\nthat catches any\nfish that touches\nit.\n\nHold Left Click\nto charge,\nand release\nto throw it!\n(1s Cooldown)'));
						case BOMBS:
							openSubState(new MessageSubSate('- BOMBS -\nItem that catches\nevery fish that is\nnear you.\n\nPress E in-game\nto activate it.\n(5s Cooldown)\n\n(Clears\nat the end\nof the round)'));
						case LAMP:
							openSubState(new MessageSubSate('- LAMP -\nLightens a area\naround you\nin deep areas.\n\n(Needs to be refilled\nat the end\nof the round)'));
						case LAMP_OIL:
							openSubState(new MessageSubSate('- LAMP OIL -\nUsed to refill\nyour lamp\nfor the next round.'));
						case FINS:
							openSubState(new MessageSubSate('- FINS -\nWill make your\ndiving speed 1.5x\nfaster while\npressing SHIFT!'));
					}
				}
			}
		}

		if (FlxG.keys.justPressed.ESCAPE) {
			FlxG.switchState(new PlayState(PlayState.level + 1));
		}
	}
}
