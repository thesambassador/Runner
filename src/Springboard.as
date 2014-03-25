package  
{
	import org.flixel.FlxG;
	import org.flixel.FlxSound;
	 /* ...
	 * @author ...
	 */
	public class Springboard extends Entity
	{
		[Embed(source = '../resources/img/springboard.png')]private static var springboard:Class;
		[Embed(source = '../resources/sound/springboard.mp3')]private static var springboardSound:Class;
		
		public var bounce : int = -500;
		public var cooldown : int = 10;
		public var curCooldown : int = 0;
		
		//public var soundSpringboard : FlxSound;
		
		public function Springboard() 
		{
			super(0, 0);
			loadGraphic(springboard, false, false);
			height = 16;
			offset.y = 16;
			this.immovable = true;
			
			//soundSpringboard = new FlxSound();
			//soundSpringboard.loadEmbedded(springboardSound);
		}
		
		override public function behavior() : void {
			if (curCooldown > 0) curCooldown -= 1;
		}
		
		override public function collidePlayer(player : Player) : void {
			if((player.y <= this.y - 17) && curCooldown == 0){
				player.Bounce(bounce * .85, bounce);
				FlxG.play(springboardSound);
				curCooldown = cooldown;
				player.springboardCount += 1;
				//soundSpringboard.play();
			}
			else {
				separate(player, this);
			}
		}
	}

}