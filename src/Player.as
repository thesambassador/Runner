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
		private var jumpVel:Number = 225.00;
		private var jumpEnergy:Number = jumpTime;
		

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
		}
		
		override public function update():void 
		{
			//reset acceleration
			this.acceleration.x = 0;
			this.acceleration.y = gravity;
			
			//determine player state

			//control responses:
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
			
			//jumping
			if (FlxG.keys[controlConfig["JUMP"]]) { //if jump energy is greater than 0, we're on the ground, or we have been holding down jump in the air
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
			else {
				jumpEnergy = 0;
			}
			
			//change things for ground/air
			if (this.isTouching(FlxObject.FLOOR)) {
				state = "ground";
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
				
				jumpEnergy = jumpTime;
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
			
			super.update();
		}
		
		public function collideTilemap(Object1:FlxObject, Object2:FlxObject) {
			FlxObject.separate(Object1, Object2);
			
			var level : FlxTilemap = Object1 as FlxTilemap;
			
		}
		
		public function collideMovingPlatform(Object1:FlxObject, Object2:FlxObject) : void{
			FlxObject.separate(Object1, Object2);
			this.acceleration.x += Object1.velocity.x;
			this.acceleration.y += Object1.velocity.y;
			
			
		}
	
		
	}
	
}