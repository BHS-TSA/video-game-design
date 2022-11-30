package;

import flixel.input.keyboard.FlxKey;
import flixel.FlxG;

class CoolData
{
	// PROGRESS STUFF
	public static var roomNumber:Int = 1; // Room number

	// CONTROLS STUFF
	public static var upKeys:Array<FlxKey> = [UP, W]; // Control array to move up
	public static var downKeys:Array<FlxKey> = [DOWN, S]; // Control array to move down
	public static var leftKeys:Array<FlxKey> = [LEFT, A]; // Control array to move left
	public static var rightKeys:Array<FlxKey> = [RIGHT, D]; // Control array to move right

	public static var confirmKeys:Array<FlxKey> = [ENTER, Z]; // Control array to confirm
	public static var backKeys:Array<FlxKey> = [ESCAPE, X]; // Control array to go back
	public static var resetKeys:Array<FlxKey> = [R]; // Control array to reset
	public static var fullscreenKeys:Array<FlxKey> = [F, NUMPADONE, ONE]; // Control array to toggle fullscreen
	public static var framesKeys:Array<FlxKey> = [NUMPADTWO, TWO]; // Control array to toggle FPS counter
	public static var skipKeys:Array<FlxKey> = [NUMPADTHREE, THREE]; // To skip levels in debug only

	public static var muteKeys:Array<FlxKey> = [NUMPADZERO, ZERO]; // Control array to mute
	public static var volumeDownKeys:Array<FlxKey> = [NUMPADMINUS, MINUS]; // Control array to lower volume
	public static var volumeUpKeys:Array<FlxKey> = [NUMPADPLUS, PLUS]; // Control array to raise volume

	// TILE STUFF
	public static var doTileCollision:Array<Int> = [4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]; // ID for each tile that the player should collide with

	// Checking important keys for frame states
	public static function backgroundKeys()
	{
		if (Main.fpsVar != null && FlxG.keys.anyJustPressed(framesKeys))
		{
			Main.fpsVar.visible = !Main.fpsVar.visible;
		}

		if (FlxG.keys.anyJustPressed(fullscreenKeys))
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		}
	}
}
