package 
{
	import org.flixel.FlxBasic;
	import org.flixel.FlxObject;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	import org.flixel.system.FlxTile;
	import org.flixel.FlxU;
	import org.flixel.FlxG;
	
	
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
		
		public static function addCoins(amount : int) : void {
			var current : int = CommonConstants.SAVE.data.Coins;
			
			current += amount;
			CommonConstants.SAVE.data.Coins = current;
			
			CommonConstants.SAVE.flush();
		}
		
		public static function saveScore(score : int) : void {
			var current : int = CommonConstants.SAVE.data.BestScore;
			
			if(score > current)
				CommonConstants.SAVE.data.BestScore = score;
			
			CommonConstants.SAVE.flush();
		}
		
		public static function saveUserSettings(name:String, group:String) : void {
			CommonConstants.SAVE.data.name = name;
			CommonConstants.SAVE.data.group = group;
			CommonConstants.SAVE.flush();
		}
		
		public static function alignX(width : int, type : String = "center", buffer : int = 0) : int {

			var targetX : int = 0;
			
			switch(type){
				case "left":
					targetX = buffer;
					break;
				case "center":
					targetX = (CommonConstants.VISIBLEWIDTH / 2) - (width / 2);
					break;
				case "right":
					targetX = CommonConstants.VISIBLEWIDTH - width - buffer;
					break;
			}
			
			return targetX;
		}
		
		public static function moveTowards(sprite : FlxSprite, target : FlxPoint, speed : Number) : Boolean {
			var dist : Number = FlxU.getDistance(new FlxPoint(sprite.x, sprite.y), target);
			if (dist < speed) {
				sprite.x = target.x;
				sprite.y = target.y;
				return true;
			}
			
			var diffX : Number = target.x - sprite.x;
			var diffY : Number = target.y - sprite.y;
			
			var move : FlxPoint = new FlxPoint();
			
			move.x = (diffX / dist) * speed;
			move.y = (diffY / dist) * speed;

			sprite.x += move.x;
			sprite.y += move.y;
			return false;
		}
		
		public function getVector(angle : Number, length : Number) : FlxPoint {
			var returned : FlxPoint = new FlxPoint();
			
			var radians : Number = angle * Math.PI/180

			returned.x = Math.cos(radians) * length;
			returned.y = Math.sin(radians) * length;
			
			return returned;
		}

	}
}