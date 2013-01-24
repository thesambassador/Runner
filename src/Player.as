package 
{
	import flash.utils.Dictionary;
	import org.flixel.*;
	import org.flixel.system.FlxAnim;
	/**
	 * ...
	 * @author Sam Tregillus
	 */
	public class Player extends FlxSprite
	{
		[Embed(source = '../resources/img/bigmario.png')]private static var marioSprites:Class;
		
		var state : String;
	
		private var controlConfig : Dictionary;
		
		public var rem : Number;
		
		//movement constants:
		private var groundDragFactor = 6;
		private var airDragFactor = 3;
		private var gravity : Number = 1000;
		
		private var walkSpeed:Number = 160;
		private var runSpeed:Number = 250;
		private var accelerationFactor:Number = 2;
		
		private var jumpTime:Number = 7;  //variable for how long you can hold down the jump button and get lift
		private var jumpVel:Number = 260.00;
		private var jumpEnergy:Number = jumpTime;
		private var canJump:Boolean = true; //variable to require releasing the jump key before being able to jump again
		public var sliding:Boolean = false; //variable to require releasing the jump key before being able to jump again
		public var wasSliding:Boolean = false; //hack job... too tired to figure out an elegant way, and this is quick, simple, and dirty.
		
		public var attacking:Boolean = false; //is the character currently attacking?
		public var attackCooldown : int = 25; //cooldown before you can do another attack
		public var attackReady : int = 0; //current readiness of the attack... gets set to attackCooldown right when you attack.
		public var attackProjectile : MeleeAttack;
		
		public var lastVel : FlxPoint;

		public function Player(xStart:int = 0, yStart:int = 0){
			super(xStart, yStart);
			
			//controls:
			controlConfig = new Dictionary();
			controlConfig["LEFT"] = "LEFT";
			controlConfig["RIGHT"] = "RIGHT";
			controlConfig["UP"] = "UP";
			controlConfig["DOWN"] = "DOWN";
			controlConfig["JUMP"] = "Z";
			controlConfig["RUN"] = "SHIFT";
			
			//movement
			this.maxVelocity.x = walkSpeed;
			this.maxVelocity.y = 700;
			this.acceleration.y = 1000;
			this.drag.x = this.maxVelocity.x * 3;
			this.lastVel = new FlxPoint();
			
			//graphics
			this.loadGraphic(marioSprites, true, true, 16, 32);
			this.frames = 4;
			this.frameWidth = 16;
			this.frameHeight = 16;
			
			//animation
			this.addAnimation("run", new Array(0, 2, 1), 10);
			this.addAnimation("idle", new Array(0, 0));
			this.addAnimation("jump", new Array(3, 3));
			this.addAnimation("fall", new Array(3, 3));
			this.addAnimation("slow", new Array(4, 4));
			this.addAnimation("slide", new Array(5, 5));
			
			this.width = 15; //so we can still fall between 2 tiles with a 1 space gap
			
			FlxG.watch(this, "y", "PlayerY");
			FlxG.watch(this, "sliding", "sliding");
			FlxG.watch(this, "wasSliding", "wasSliding");
			FlxG.watch(this, "attackReady", "attackReady");
		}
		
		override public function update():void 
		{
			//reset acceleration
			this.acceleration.x = 0;
			this.acceleration.y = gravity;
			
			wasSliding = sliding;
			
		
			//determine player state
			
			if (this.isTouching(FlxObject.FLOOR)) {
				state = "ground";
				jumpEnergy = jumpTime;
			}
			
			if(!sliding){
				//control responses:
				updateMovement();

				//now do a slide thing?
				if (this.isTouching(FlxObject.FLOOR) && FlxG.keys.justPressed(controlConfig["DOWN"]) && !this.isTouching(FlxObject.WALL)) {
					this.sliding = true;
					this.setBoundHeight(15);
				}
			}
			else {
				
				this.drag.x = this.maxVelocity.x * 1; //less drag for sliding... weeee
				this.play("slide");
				if (!FlxG.keys[controlConfig["DOWN"]] || !this.isTouching(FlxObject.FLOOR)) {
					this.sliding = false;
					this.setBoundHeight(32);
					this.y -= 1;
				}
			}

			
			updateJumping();
			updateAttacking();
		
			super.update();
			
			this.velocity.copyTo(lastVel);
		}
		
		
		private function updateMovement() {
			//movement 
			if (FlxG.keys[controlConfig["RUN"]]) {
				this.maxVelocity.x = runSpeed;
			}
			else {
				this.maxVelocity.x = walkSpeed;
			}
			
			if (FlxG.keys[controlConfig["LEFT"]]) {
				this.facing = FlxObject.LEFT;
				this.acceleration.x = -this.maxVelocity.x * accelerationFactor;
			}
			else if ((FlxG.keys[controlConfig["RIGHT"]])) {
				this.facing = FlxObject.RIGHT;
				this.acceleration.x = this.maxVelocity.x * accelerationFactor;
			}
			
			//change things for ground/air
			if (this.isTouching(FlxObject.FLOOR)) {;
				this.drag.x = this.maxVelocity.x * groundDragFactor;
				
				
				if (this.acceleration.x * this.velocity.x < 0) {
					this.play("slow");
					this.acceleration.x *= 2
				}
				else if (Math.abs(this.velocity.x) > 0) {
					this.play("run");
				}
				else {
					this.play("idle");
				}
			}
			//air state
			else {
				state = "air";
				this.drag.x = this.maxVelocity.x * airDragFactor;
				
				if (this.velocity.y > 0) {
					this.play("jump");
				}
				else {
					this.play("fall");
				}
			}
		}
		
		private function updateJumping() {
			//jumping
			if (FlxG.keys[controlConfig["JUMP"]] && canJump) { //if jump energy is greater than 0, we're on the ground, or we have been holding down jump in the air
				if(jumpEnergy > 0){
					if (jumpEnergy >= jumpTime - 3) {
						this.velocity.y = -jumpVel / 1.5;
					}
					else if (jumpEnergy >= jumpTime - 5) {
						this.velocity.y = -jumpVel / 1.2;
					}
					else {
						this.velocity.y = -jumpVel;
					}
					jumpEnergy -= 1;
				}

			}
			else{
				jumpEnergy = 0;
				
			}
		}
		
		private function updateAttacking() {
			if (attackReady > 0) attackReady --;
		
			
			//ATTACK
			if(!sliding){
				if (FlxG.keys.justPressed(controlConfig["RUN"]) && attackReady == 0) {
					attackReady = attackCooldown;
					attackProjectile = new MeleeAttack(this.x + 20, this.y, this);
					attackProjectile.facing = this.facing;
					FlxG.state.add(attackProjectile);
				}
			}
		}
		
		public function setBoundHeight(h:int) {
			this.y += this.height - h;
			this.height = h;

			this.offset.y = 32 - this.height;
		}
		
		public function collideTilemap(tilemap:FlxObject, playerObj:FlxObject) {
			
			var player : Player = playerObj as Player;
			
			var originalPosX : Number = player.x;
			var originalPosY : Number = player.y;

			FlxObject.separate(tilemap, player);
			
			//if the above separation function detected us touching the ceiling, but we were sliding, it's because we came up from sliding under a wall.
			if (player.isTouching(FlxObject.CEILING) && player.wasSliding) {
				//undo y separation
				player.y = originalPosY;
				
				//put back to sliding
				player.sliding = true;
				player.setBoundHeight(15);
				
				var dir : Number = (lastVel.x > 0) ? 1 : -1;
				player.velocity.x = dir * (player.maxVelocity.x / 2 + 10);
				
			}
			
		}
		
		public function collideMovingPlatform(Object1:FlxObject, Object2:FlxObject) : void{
			FlxObject.separate(Object1, Object2);
			this.acceleration.x += Object1.velocity.x;
			this.acceleration.y += Object1.velocity.y;
			
			
		}
	
		
	}
	
}