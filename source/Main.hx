class Main extends Sprite {
	public function new() {
		super();

		addChild(new FlxGame(192, 174, PlayState, 120, 120));
	}
}
