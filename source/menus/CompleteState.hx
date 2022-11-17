package menus;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class CompleteState extends FrameState
{
	// The UI varaibles
	var winText:FlxText;

	override function create()
	{
		// Setup the UI
		winText = new FlxText();
		winText.text = 'To Be Continued... \n You have completed all avalible levels. \n Press Enter to play again.';
		winText.alignment = CENTER;
		winText.screenCenter();

		add(winText);

		super.create();

		// Cool fade to make it smoother
		FlxG.camera.fade(FlxColor.BLACK, 3, true);
	}

	override function update(elapsed:Float)
	{
		// Check to see if the player has confirmed
		if (FlxG.keys.anyJustPressed(CoolData.confirmKeys))
		{
			pressStart();
		}

		super.update(elapsed);
	}

	function pressStart()
	{
		// Fade to black and then go to PlayState again
		FlxG.camera.fade(FlxColor.BLACK, 0.1, false, function()
		{
			CoolData.roomNumber = 1;
			FlxG.switchState(new gameplay.PlayState());
		});
	}
}