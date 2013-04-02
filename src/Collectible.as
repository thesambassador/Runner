package 
{
	import org.flixel.FlxSprite;
	
	/**
	 * ...
	 * @author ...
	 */
	public class Collectible extends FlxSprite 
	{
		[Embed(source = '../resources/img/collectible.png')]private static var collectibleImage:Class;
		
		public function Collectible(startX:int = 0, startY:int = 0) 
		{
			super(startX, startY);
			super.loadGraphic(collectibleImage, true, false, 16, 16);
			//this.moves = false;
			//this.solid = false;
			//this.mass = .1;
		}
		
		public function playerCollide(playerObj:Player) {
			playerObj.collectiblesCollected ++;
			this.kill();
		}
	
			
	}
	
}