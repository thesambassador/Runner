package 
{
	import org.flixel.FlxSprite;
	import org.flixel.FlxSound;
	import org.flixel.FlxG;
	
	/**
	 * ...
	 * @author ...
	 */
	public class Collectible extends Entity 
	{
		[Embed(source = '../resources/img/collectible.png')]private static var collectibleImage:Class;
		
		public function Collectible(startX:int = 0, startY:int = 0) 
		{
			super(startX, startY);
			super.loadGraphic(collectibleImage, true, false, 16, 16);
			
			this.addAnimation("pulse", [1, 2, 3, 2, 1], 4);
			this.play("pulse");
		}
		
		override public function collidePlayer(playerObj:Player) : void {
			if(this.exists){
				playerObj.collectCollectible(this);
				
				
				this.kill();
			}
		}
	
			
	}
	
}