package  
{
	import org.flixel.FlxObject;
	/**
	 * ...
	 * @author ...
	 */
	public class DeathProjectile extends Entity
	{
		var velX : Number = 0;
		var velY : Number = 0;
		
		public function DeathProjectile(image : Class, sizeX: int, sizeY: int, speedX : int, speedY : int, numFrames : int = 1) 
		{
			super(0, 0);
			loadGraphic(image, true, true, sizeX, sizeY);
			this.width = sizeX - 4;
			this.height = sizeY - 4;
			this.centerOffsets();
			velX = speedX;
			velY = speedY;
			
			var frames : Array = new Array();
			for (var i : int = 0; i < numFrames; i++) {
				frames.push(i);
			}
			this.addAnimation("anim", frames, 10);
			
			activationDistance = 600;
		}
		
		override public function collidePlayer(player : Player) : void{
			player.hurt(1);
		}
		
		override public function PausedState() : void {
			this.velocity.x = 0;
			this.velocity.y = 0;
		}
		
		override public function behavior() : void {
			this.velocity.x = velX;
			this.velocity.y = velY;
			this.facing = this.velocity.x >= 0 ? FlxObject.RIGHT : FlxObject.LEFT
			this.play("anim");
		}
		
	}

}