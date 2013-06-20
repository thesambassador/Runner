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
			player.kill();
		}
		
		public static function addCoins(amount : int) {
			var current : int = CommonConstants.SAVE.data.Coins;
			
			current += amount;
			CommonConstants.SAVE.data.Coins = current;
			
			CommonConstants.SAVE.flush();
		}
		
		public static function saveScore(score : int) {
			var current : int = CommonConstants.SAVE.data.BestScore;
			
			if(score > current)
				CommonConstants.SAVE.data.BestScore = score;
			
			CommonConstants.SAVE.flush();
		}
		
	}
	
}