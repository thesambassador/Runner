package  
{
	import org.flixel.FlxSprite;
	import org.flixel.FlxG;
	import org.flixel.FlxTilemap;
	import org.flixel.FlxObject;
	
	/**
	 * ...
	 * @author ...
	 */
	public class Enemy extends FlxSprite 
	{
		[Embed(source = '../resources/img/enemies.png')]private static var enemySprites:Class;

		private var moveSpeed : Number = 50;
		private var gravity : Number = 1000;
		private var removeTime: Number = 20;
		
		public function Enemy(startX:int = 0, startY:int = 0) 
		{
			super(startX, startY);
			super.loadGraphic(enemySprites, true, true, 16, 16);
			
			this.addAnimation("run", new Array(0, 1), 5);
			this.addAnimation("die", new Array(2, 2), 5);
			
		}
		
		public function ChangeDirection() {
			moveSpeed *= -1;
			
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
		
		public function collidePlayer(player : Player) {
			if (player.velocity.y > 0 && player.y + player.height < this.y + 20) {
				this.health = 0;
				player.EnemyBounce();
			}
			else if(health > 0){
				player.hurt(1);
			}
		}
		
		public function collideEnemy(enemy : Enemy) {
			this.ChangeDirection();
			enemy.ChangeDirection();
			separate(this, enemy);
		}
		
		public function collideTilemap(tilemap : FlxTilemap) {
			if (this.isTouching(FlxObject.WALL)) {
				this.ChangeDirection();
			}
		}
		
		
	}

}