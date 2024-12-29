@:publicFields
class Util {
    static function getPixelFont() {
        return FlxBitmapFont.fromMonospace(AssetPaths.ATARIPL__png, // chars
            " !\"ĆŁ%Ń'()*+,-./0123456789:;<=>?" + // row 1
            "ŚABCDEFGHIJKLMNOPQRSTUVWXYZŹ\\Ż^_" + // row 2
            "♡ą|ć˧ę╱╲◢▗◣▝ł▔ńó♣┏━ś⬤▄▏┳ź▌ż␛↑↓←→" + // row 3
			"♦abcdefghijklmnopqrstuvwxyz♠┃" + // row 4
			"$" // row 5 (other)
        , FlxPoint.get(8, 8));
    }

    static function percentOf(value:Float, max:Float):Int {
        if (value == 0 || max == 0)
            return 0;

        return Math.ceil(Math.min(value / max, 1) * 100);
    }
}