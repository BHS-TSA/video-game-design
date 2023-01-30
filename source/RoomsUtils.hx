package;

import flixel.FlxG;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class RoomsUtils
{
	inline static public function getText(key:String):String
	{
		return OpenFlAssets.getText(Paths.getPath('$key'));
	}

	inline static public function getCoolText(key:String):Array<String>
	{
		var daList:Array<String> = getText(key).trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function openURL(site:String)
	{
		#if linux
		Sys.command('/usr/bin/xdg-open', [site]);
		#else
		FlxG.openURL(site);
		#end
	}
}