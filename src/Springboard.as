package  
{
	import org.flixel.FlxG;
	 /* ...
	 * @author ...
	 */
	public class Springboard extends Entity
	{
		[Embed(source = '../resources/img/springboard.png')]private static var springboard:Class;
		
		var bounce : int = -500;
		
		public function Springboard() 
		{
			super(0, 0);
			loadGraphic(springboard, false, false);
			height = 16;
			offset.y = 16;
			this.immovable = true;
		}
		
		override public function collidePlayer(player : Player) : void {
			if(player.y <= this.y - 17){
				player.Bounce(bounce * .85, bounce);
			}
			else {
				separate(player, this);
			}
		}
	}

}