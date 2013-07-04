package  
{
	import org.flixel.FlxEmitter;
	import org.flixel.FlxParticle;
	import org.flixel.FlxSprite;
	import org.flixel.FlxObject;
	import org.flixel.FlxG;
	import org.flixel.FlxTilemap;
	/**
	 * ...
	 * @author ...
	 */
	public class EnemyJumper extends Entity
	{
		[Embed(source = '../resources/img/EnemyJumper.png')]private static var enemySprites:Class;
		[Embed(source = '../resources/sound/enemyKill.mp3')]private static var enemyKillSound:Class;
		
		public var state : String = "ground";
		
		private var howLongOnGround : int = 50;
		
		private var timeOnGround : int = 0;
		
		private var jumpVelocityY : int = -300;
		private var jumpVelocityX : int = -150;
		private var gravity : Number = 1000;
		
		public function EnemyJumper(startX:int = 0, startY:int = 0) 
		{
			//super(startX, startY);
			super.loadGraphic(enemySprites, true, true, 32, 32);
			this.height = 18
			this.offset.y = 14;
			
			this.activationDistance = 400;
			this.addAnimation("jump", new Array(0, 1, 2, 3, 4, 4, 5), 10, false);
			this.addAnimationCallback(animHandler);
			this.addAnimation("land", new Array(5, 6, 0), 20, false);
			this.addAnimation("death", new Array(3, 3, 3, 3), 10, false);
			//FlxG.watch(this, "frame", "EnemyFrame");
			
			this.facing = FlxObject.LEFT;
		}
		
		public function animHandler(animName:String, frameNum:uint, frameIndex:uint) : void {
			var dir : int = this.facing == FlxObject.LEFT ? 1 : -1;
			if (animName == "jump" && frameNum == 4) {
				this.y --;
				this.velocity.y = jumpVelocityY;
				this.velocity.x = jumpVelocityX * dir;
				state = "air";
			}
			else if (animName == "death") {
				if(frameNum == 3)
					this.kill();
				else {
					EmitParticles();
				}
			}
			
		}
		
		public function EmitParticles() : void {
			var emitter : FlxEmitter = new FlxEmitter(0,0);
			emitter.at(this);
			
			for (var i:int = 0; i < 10; i++){
				emitter.add(deathParticle);
				var deathParticle : FlxParticle = new FlxParticle();
			
				deathParticle.makeGraphic(2, 2, 0xff009900);
				deathParticle.exists = false;
			}
			
			emitter.gravity = 1000;

			emitter.minParticleSpeed.y = -200;
			emitter.maxParticleSpeed.x = 50;
			emitter.minParticleSpeed.x = -50;
			
			(FlxG.state as PlayState).world.particles.add(emitter)
			emitter.start(true, 1, 1, 0);
		}
		
		override public function behavior() : void {
			if(this.health > 0){
				if (this.justTouched(FlxObject.WALL)) {
					this.velocity.x *= -1;
					this.facing = this.facing == FlxObject.RIGHT ? FlxObject.LEFT : FlxObject.RIGHT;
				}
				this.acceleration.y = gravity;
				switch(state) {
					case "ground": 
						this.drag.x = 500;
						timeOnGround ++;
						if (timeOnGround > howLongOnGround) {
							this.play("jump");
						}
						break;
					case "air": 
						this.drag.x = 0;
						if (this.isTouching(FlxObject.FLOOR)) {
							this.play("land");
							timeOnGround = 0;
							state = "ground";
						}
						break;
				}
			}
			else {
				
				this.play("death");
				

			}
			
		}
		
		override public function collideTilemap(tilemap : FlxTilemap) : void {
			separate(this, tilemap);
		}
		
		override public function collidePlayer(player : Player) : void {
			var playerBounce : Boolean = player.y + player.height < this.y + 10 && this.health > 0;
			
			if (playerBounce) {
				player.Bounce( -150, -400);
			}
			
			if (playerBounce || player.invulnerable) {
				this.health = 0;
				player.addScore(500);
				player.enemiesKilled += 1;
				FlxG.play(enemyKillSound);
			}
			else if(health > 0){
				player.hurt(1);
			}
		}

	}

}