package;

import flixel.FlxState;

class FrameState extends FlxState
{
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		// Check keys
		CoolData.backgroundKeys();
	}
}
