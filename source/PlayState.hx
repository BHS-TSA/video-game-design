package;

import Player;
import Prop;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

using StringTools;

class PlayState extends FrameState
{
	// Camera stuff
	var camGame:FlxCamera;
	var camUI:FlxCamera;

	// The world variables
	public static var map:FlxOgmo3Loader;
	public static var walls:FlxTilemap;
	public static var walls2:FlxTilemap;

	public static var door:Prop;
	public static var propGrp:FlxTypedGroup<Prop>;

	// The player variable
	public static var player:Player;

	// The UI stuff
	public static var overlay:FlxSprite;

	var levelText:FlxText;
	var denyText:FlxText;

	override public function create()
	{
		// Hide the mouse if there is one
		#if FLX_MOUSE
		FlxG.mouse.visible = false;
		#end

		// Set up the cameras
		camGame = new FlxCamera();
		camUI = new FlxCamera();
		camUI.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camUI, false);

		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		// UI stuffs
		overlay = new FlxSprite();
		overlay.loadGraphic(Paths.image('overlay'));
		overlay.cameras = [camUI];

		levelText = new FlxText(0, 5, 0, "- LEVEL ??? -", 10);
		levelText.alignment = CENTER;
		levelText.screenCenter(X);
		levelText.cameras = [camUI];

		denyText = new FlxText(0, FlxG.height * 0.8, "Denied.", 10);
		denyText.alignment = FlxTextAlign.CENTER;
		denyText.screenCenter(X);
		denyText.cameras = [camUI];
		denyText.alpha = 0;

		// Setup the level
		reloadLevel();

		// ADD THINGS
		add(overlay);
		add(levelText);
		add(denyText);

		// Finish setting up the camera
		camGame.follow(player, TOPDOWN, 1);

		super.create();
		stopCompleteSpam = false;

		// Play some music
		if (CoolData.roomNumber == 1)
		{
			FlxG.sound.music.stop();
			FlxG.sound.playMusic(Paths.music('funkysuspense'), 0.7, true);
		}

		// Epic transition
		camUI.fade(FlxColor.BLACK, 0.1, true);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		// Check to see if the player needs help
		if (FlxG.keys.anyJustPressed(CoolData.pauseKeys))
		{
			openSubState(new PauseSubState());
		}

		// Collision stuff
		FlxG.collide(player, walls);

		// Update the overlay
		if (PlayState.player != null)
		{
			overlay.x = player.getScreenPosition().x - overlay.width / 2;
			overlay.y = player.getScreenPosition().y - overlay.height / 2;
		}
		else
		{
			overlay.screenCenter();
		}

		propGrp.forEach(function(spr:Prop)
		{
			// If this prop is to be ignored, ignore it
			if (!CoolData.allowPropCollision.contains(spr.my_type))
			{
				FlxG.collide(player, spr);
			}

			// Check for overlaps
			if (spr.my_type == SHAPELOCK)
			{
				if (player.overlaps(spr) && door.isOpen == false)
				{
					spr.animation.play('hover');

					if (FlxG.keys.anyJustPressed(CoolData.confirmKeys))
					{
						openSubState(new ShapePuzzleSubstate());
					}
				}
				else
				{
					if (door.isOpen == true)
					{
						spr.animation.play('complete');
					}
					else
					{
						spr.animation.play('normal');
					}
				}
			}
			else if (spr.my_type == HINT)
			{
				if (player.overlaps(spr) && (door.isOpen == false || CoolData.roomNumber == 1))
				{
					spr.animation.play('hover');

					if (FlxG.keys.anyJustPressed(CoolData.confirmKeys))
					{
						openSubState(new HintSubstate(spr.hintType));
					}
				}
				else
				{
					spr.animation.play('normal');
				}
			}
			else if (spr.my_type == KEY)
			{
				if (player.overlaps(spr) && door.isOpen == false)
				{
					spr.animation.play('hover');

					if (FlxG.keys.anyJustPressed(CoolData.confirmKeys))
					{
						door.isOpen = true;
						spr.kill();

						trace("KEY LOCATED!!!!!!");
						denyText.text = 'Door has been unlocked.';
						denyText.screenCenter(X);
						denyText.alpha = 1;
						FlxTween.tween(denyText, {alpha: 0}, 2, {startDelay: 1});
					}
				}
				else
				{
					spr.animation.play('normal');
				}
			}
		});

		if (player.overlaps(door))
		{
			if (door.isOpen)
			{
				door.animation.play('open_s');

				if (!stopCompleteSpam && FlxG.keys.anyJustPressed(CoolData.confirmKeys))
				{
					completeLevel();
				}
			}
			else
			{
				door.animation.play('closed_s');

				if (FlxG.keys.anyJustPressed(CoolData.confirmKeys))
				{
					trace("DOOR IS LOCKED BOZO!!!");
					denyText.text = 'This door is locked.';
					denyText.screenCenter(X);
					denyText.alpha = 1;
					FlxTween.tween(denyText, {alpha: 0}, 2, {startDelay: 1});
				}
			}
		}
		else
		{
			if (door.isOpen)
			{
				door.animation.play('open');
			}
			else
			{
				door.animation.play('closed');
			}
		}
	}

	function placeEntities(entity:EntityData) // Setup the props
	{
		var x = entity.x;
		var y = entity.y;

		switch (entity.name)
		{
			case "player":
				player.setPosition(x + (16 - Player.physicsJSON.hitbox) / 2, y + (16 - Player.physicsJSON.hitbox) / 2);

			case "door":
				door = new Prop(x - 8, y, DOOR);
				door.isOpen = !entity.values.locked;
				add(door);

			case 'torch':
				propGrp.add(new Prop(x, y, TORCH));

			case 'shapelock':
				propGrp.add(new Prop(x - 8, y, SHAPELOCK));
				ShapePuzzleSubstate.shuffleCombo();

			case 'crate':
				propGrp.add(new Prop(x + 1, y + 1, CRATE));

			case 'barrel':
				propGrp.add(new Prop(x + 4, y + 2, BARREL));

			case 'vase':
				propGrp.add(new Prop(x + 5, y + 5, VASE));

			case 'bookshelf':
				propGrp.add(new Prop(x, y, BOOKSHELF));

			case 'hint':
				var hint:Prop = new Prop(x - 8, y - 8, HINT);
				hint.hintType = entity.values.hintType;
				propGrp.add(hint);

			case 'key':
				propGrp.add(new Prop(x - 8, y - 8, KEY));

			default:
				trace('Unrecognized actor type ' + entity.name);
		}
		add(propGrp);
	}

	public function chooseLevel():String
	{
		var fullText:String = Paths.getText('data/_gen/' + Std.string(CoolData.roomNumber) + '.txt').trim();
		var swagArray:Array<String> = fullText.split('\n');
		for (i in 0...swagArray.length)
		{
			swagArray[i] = swagArray[i].trim();
		}
		var swagItem:String = FlxG.random.getObject(swagArray);
		trace('Chose $swagItem from $swagArray');

		return swagItem;
	}

	public function reloadLevel()
	{
		// Reload the UI
		levelText.text = '- Room ' + CoolData.roomNumber + ' -';
		levelText.screenCenter(X);

		// Build the level
		var tempLvl:String = chooseLevel();

		map = new FlxOgmo3Loader(Paths.getOgmo(), Paths.json('_levels/$tempLvl'));
		walls = map.loadTilemap(Paths.image('tileset'), "walls");
		walls.follow(camGame);
		walls2 = map.loadTilemap(Paths.image('tileset'), "no_collision");

		// Setup the collision
		for (i in 0...CoolData.tileCount)
		{
			if (CoolData.doTileCollision.contains(i))
			{
				walls.setTileProperties(i, ANY);
			}
			else
			{
				walls.setTileProperties(i, NONE);
			}
		}

		// Finalize and add stuff
		add(walls);
		add(walls2);
		player = new Player();
		propGrp = new FlxTypedGroup<Prop>();
		map.loadEntities(placeEntities, "decor");
		map.loadEntities(placeEntities, "utils");
		add(player);
	}

	static var stopCompleteSpam:Bool = false; // Stop people from breaking the level

	public static function completeLevel()
	{
		stopCompleteSpam = true;

		// TO THE NEXT LEVEL WOOOOOOOO
		CoolData.roomNumber += 1;

		// Fade to black and then figure out what to do
		FlxG.cameras.list[FlxG.cameras.list.length - 1].fade(FlxColor.BLACK, 0.1, false, function()
		{
			// Check to see if a file exists, and then go to the next level if it does
			if (Paths.fileExists('data/_gen/' + CoolData.roomNumber + '.txt'))
			{
				FlxG.resetState();
			}
			else
			{
				FlxG.switchState(new CompleteState());
			}
		});
	}
}
