package  
{
	import org.flixel.FlxSave;
	import org.flixel.FlxSound;
	import org.flixel.FlxSprite;
	import org.flixel.FlxG;
	import org.flixel.FlxTilemap;
	import org.flixel.FlxObject;
	import org.flixel.FlxEmitter;
	import org.flixel.FlxParticle;
	
	/**
	 * ...
	 * @author ...
	 */
	public class EnemyWalker extends Entity 
	{
		[Embed(source = '../resources/img/slime.png')]private static var enemySprites:Class;
		[Embed(source = '../resources/sound/enemyKill.mp3')]private static var enemyKillSound:Class;

		private var moveSpeed : Number = 50;
		private var currentSpeed : Number = 0;
		private var gravity : Number = 1000;
		private var removeTime: Number = 20;
	
		
		public function EnemyWalker(startX:int = 0, startY:int = 0) 
		{
			super(startX, startY);
			super.loadGraphic(enemySprites, true, true, 32, 32);
			this.height = 24;
			this.offset.y = 8;
			this.width = 28;
			this.activationDistance = 400;
			
			currentSpeed = -moveSpeed;

			this.facing = FlxObject.LEFT;
			this.addAnimation("run", new Array(0, 1, 2), 10);
			this.addAnimation("die", new Array(5, 6, 7, 8, 9, 9, 9, 9), 20, false);
			this.addAnimationCallback(handleAnimation);

		}
		
		public function ChangeDirection() : void {
			if(this.isTouching(FlxObject.LEFT) && moveSpeed < 0){
				moveSpeed = Math.abs(moveSpeed);
				this.facing = FlxObject.RIGHT;
			}
			else if (this.isTouching(FlxObject.RIGHT) && moveSpeed >= 0) {
				moveSpeed = -moveSpeed;
				this.facing = FlxObject.LEFT;
			}
			//this.x += moveSpeed * 1 / 60;
		}
		
		public function handleAnimation(animName : String, framenum : uint, frameIndex : uint ) : void {
			if (animName == "die") {
				if (framenum > 2)
					EmitParticles();
				if (framenum > 6) {
					this.kill();
					this.activated = false;
				}
			}
		}
		
		public function EmitParticles() : void{
			var emitter : FlxEmitter = new FlxEmitter(0,0);
			emitter.at(this);
			
			for (var i:int = 0; i < 10; i++){
				emitter.add(deathParticle);
				var deathParticle : FlxParticle = new FlxParticle();
			
				deathParticle.makeGraphic(2, 2, 0xff009900);
				deathParticle.exists = false;
			}
			
			emitter.gravity = 1000;
			emitter.setSize(15, 16);
			
			emitter.minParticleSpeed.y = -200;
			emitter.maxParticleSpeed.x = 100;
			emitter.minParticleSpeed.x = -100;
			
			(FlxG.state as PlayState).world.particles.add(emitter)
			emitter.start(true, 1, 1, 0);
		}
		
		override public function behavior() : void {
		
			if (this.health > 0) {
				this.play("run");
				this.velocity.x = currentSpeed;
				this.acceleration.y = gravity;
			}
			else {
				if(this._curAnim.name != "die")
					this.play("die");

			}
			
			//this.ChangeDirection();
			
		}
		
		override public function collidePlayer(player : Player) : void {
			var playerBounce : Boolean = player.y + player.height < this.y + 10 && this.health > 0;
			
			if (playerBounce) {
				player.Bounce( -150, -400);
			}
			
			if (this.health > 0 && (playerBounce || player.invulnerable)) {
				FlxG.play(enemyKillSound); 
				this.health = 0;
				player.addScore(200);
				player.enemiesKilled += 1;
			}
			else if(health > 0){
				player.hurt(1);
			}

			else {
				
				this.health = 0;
			}
		}
		
		override public function collideEnemy(enemy : Entity) : void {
			if (enemy is EnemyWalker) {
				var walker : EnemyWalker = enemy as EnemyWalker;
				separate(this, enemy);
				if (this.isTouching(FlxObject.LEFT)) {
					currentSpeed = moveSpeed;
					this.facing = FlxObject.RIGHT;
					walker.currentSpeed = -moveSpeed;
					walker.facing = FlxObject.LEFT;
					
				}	
				else if (this.isTouching(FlxObject.RIGHT)) {
					currentSpeed = -moveSpeed;
					this.facing = FlxObject.LEFT;
					walker.currentSpeed = moveSpeed;
					walker.facing = FlxObject.RIGHT;
				}
			}
		}
		
		override public function collideTilemap(tilemap : FlxTilemap) : void {
			//FlxG.collide(this, tilemap);
			
			separate(this, tilemap);
			
			if (this.isTouching(FlxObject.LEFT)) {
				currentSpeed = moveSpeed;
				this.facing = FlxObject.RIGHT;
			}
			else if (this.isTouching(FlxObject.RIGHT)) {
				currentSpeed = -moveSpeed;
				this.facing = FlxObject.LEFT;
			}
			
			
		}
		
		
	}

}