package  
{
	import org.flixel.FlxSprite;
	import org.flixel.FlxG;
	
	/**
	 * ...
	 * @author ...
	 */
	public class Enemy extends FlxSprite 
	{
		[Embed(source = '../resources/img/enemies.png')]private static var enemySprites:Class;

		private var moveSpeed = 50;
		private var gravity : Number = 1000;
		private var removeTime: Number = 20;
		
		public function Enemy(startX:int, startY:int) 
		{
			super(startX, startY);
			super.loadGraphic(enemySprites, true, false, 16, 16);
			
			this.addAnimation("run", new Array(0, 1), 5);
			this.addAnimation("die", new Array(2, 2), 5);
			
			FlxG.watch(this, "x", "EnemyX");
			FlxG.watch(this, "y", "EnemyY");
		}
		
		override public function update() : void {
			
			//only update this if it's in the world bounds, otherwise things will fall on the ground.
			if(this.x >= FlxG.worldBounds.left && this.x <= FlxG.worldBounds.right){
				if (this.health > 0) {
					this.play("run");
					this.velocity.x = -moveSpeed;
					this.acceleration.y = gravity;
				}
				else {
					this.play("die");
					removeTime --;
					if (removeTime <= 0) {
						this.kill();
					}
				}
			}
		}
		
		
		
	}

}