package 
{
	import org.flixel.FlxObject;
	import org.flixel.FlxSprite;
	import org.flixel.system.FlxTile;
	
	/**
	 * ...
	 * @author ...
	 */
	public class CommonFunctions
	{
		public static function getRandom(min:int, max:int) : int {
			return Math.round(Math.random() * (max - min)) + min;
		}
		
		public static function killPlayer(tile : FlxTile, player:FlxObject) : void {
			player.hurt(1);
		}
		
	}
	
}