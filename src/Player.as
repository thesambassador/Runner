package 
{
	import org.flixel.*;
	/**
	 * ...
	 * @author Sam Tregillus
	 */
	public class Player extends FlxSprite
	{
		
		[Embed(source = 'mario.png')]private static var marioSprites:Class;
		
		private static var jumpTime:Number = 7;  //variable for how long you can hold down the jump button and get lift
		private var jumpEnergy:Number = jumpTime;
		private var jumpVel:Number = 225.00;
		
		private var walkSpeed:Number = 160;
		private var runSpeed:Number = 250
		
		private var jumpButton:String = "Z";
		private var runButton:String = "SHIFT"
		
		public var onWall : Number = 0;  //0 = not on a wall, 1=on a wall to the left, 2= on a wall to the right
		public var stickTime : Number = 2;
		private var timetostick: Number = 5;
	
		private var gravity : Number = 1000;
		
		private var hanging : Boolean = false;
		private var canGrab : Number = 0;  //0 = no, 1 = cangrab left, 2 = can grab right
		
		public var rem : Number;
		
		public function Player(xStart:int = 0, yStart:int = 0){
			super(xStart, yStart);
		
			//movement
			this.maxVelocity.x = walkSpeed;
			this.maxVelocity.y = 700;
			this.acceleration.y = 1000;
			this.drag.x = this.maxVelocity.x * 3;
			
			//graphics
			this.loadGraphic(marioSprites, true, true, 16, 16);
			this.frames = 4;
			this.frameWidth = 16;
			this.frameHeight = 16;
			
			//animation
			this.addAnimation("run", new Array(0, 1), 10);
			this.addAnimation("idle", new Array(0, 0));
			this.addAnimation("jump", new Array(2, 2));
			this.addAnimation("fall", new Array(3, 3));
			this.addAnimation("slow", new Array(4, 4));
			
			this.width = 15; //so we can still fall between 2 tiles with a 1 space gap
		}
		
		override public function update():void 
		{
			this.acceleration.x = 0;
			this.acceleration.y = 0;
			
			if(!hanging){
				this.acceleration.y = gravity;
				
				if (stickTime > 0) {
					stickTime --;
				}
				else {
					onWall == 0;
				}
				
				var runMod : Number = 1;
				
				if (FlxG.keys[runButton]) 
				{
					this.maxVelocity.x = runSpeed;
				}
				else {
					this.maxVelocity.x = walkSpeed;
				}
				
				
				//move left or right
				if (FlxG.keys.LEFT) {
					//if we're not stuck to a right wall or if wall stick is 0:
					if(onWall != 2 || stickTime == 0)
						this.acceleration.x = -this.maxVelocity.x * 4 * runMod;
					this.facing = FlxObject.LEFT;
					if (this.isTouching(FlxObject.FLOOR)) {
						if (this.velocity.x > 0) {
							this.play("slow");
						}
						else{
							this.play("run");
						}
					}
				}
				else if (FlxG.keys.RIGHT) {
					//if we're not stuck to a left wall or if wall stick is 0:
					if(onWall != 1 || stickTime == 0)
						this.acceleration.x = this.maxVelocity.x * 4 * runMod;
					this.facing = FlxObject.RIGHT;
					if(this.isTouching(FlxObject.FLOOR)){
						if (this.velocity.x < 0) {
							this.play("slow");
						}
						else{
							this.play("run");
						}
					}
				}
				else {
					this.play("idle");
					
				}
				
				//touching floor
				if(this.isTouching(FlxObject.FLOOR)){
					jumpEnergy = jumpTime;
					onWall = 0;
					this.drag.x = this.maxVelocity.x * 6;
				}
				//not touching floor
				else {
					this.drag.x = this.maxVelocity.x * 3;
					//release the key, can't jump any more
					if (!FlxG.keys[jumpButton]) {
						jumpEnergy = 0;
					}
					//play falling animation as we go down
					if (this.velocity.y > 0) {
						this.play("fall");
					}
					//play jumping animation as we go up
					else if (this.velocity.y < 0) {
						this.play("jump");
					}
					
					//determine wall stick stuff here:
					if (isTouching(FlxObject.LEFT)) {
						onWall = 1;
						stickTime = timetostick;
						if(this.velocity.y > 0)
							this.acceleration.y -= 500;
					}
					else if (isTouching(FlxObject.RIGHT)) {
						onWall = 2;
						stickTime = timetostick;
						if(this.velocity.y > 0)
							this.acceleration.y -= 500;

					}
				}
				
				//jumping stuff
				if (FlxG.keys[jumpButton] && jumpEnergy > 0) {
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
				
				//wall jump stuff
				else if (FlxG.keys.justPressed(jumpButton)) {
					if (onWall == 1) {
						this.velocity.y -= jumpVel;
						this.velocity.x += runSpeed;
						this.onWall = 0;
						this.stickTime = 0;
					}
					else if (onWall == 2) {
						this.velocity.y -= jumpVel * .8;
						this.velocity.x -= runSpeed;
						this.onWall = 0;
						this.stickTime = 0;
					}
				}
			} //end hanging
				else { //if hanging
					this.velocity.y = 0;
					if (FlxG.keys.justPressed(jumpButton)) {
						this.velocity.y -= jumpVel;
						hanging = false;
					}
				}
			
			super.update();
		}
		
		public function collideTilemap(Object1:FlxObject, Object2:FlxObject) {
			FlxObject.separate(Object1, Object2);
			
			var level : FlxTilemap = Object1 as FlxTilemap;
			
			var tilePosX : Number = Math.floor(this.x / 16);
			var tilePosY : Number = Math.floor(this.y / 16);
			
			if (this.isTouching(FlxObject.LEFT) && this.velocity.y > 0) {
				//tile to the left and down 1 from the current position
				
				var tile = level.getTile(tilePosX - 1, tilePosY + 1);
				var tile2 = level.getTile(tilePosX - 1, tilePosY);
				
				if ( tile != 0 && tile2 == 0) {
					this.rem = this.y % 16;
					if (Math.abs(rem) > 14) {
						hanging = true;
					}
				}
				
			}
			else if (this.isTouching(FlxObject.RIGHT) && this.velocity.y > 0) {
				//tile to the right and down 1 from the current position
				
				var tile = level.getTile(tilePosX + 1, tilePosY + 1);
				var tile2 = level.getTile(tilePosX + 1, tilePosY);
				
				if ( tile != 0 && tile2 == 0) {
					this.rem = this.y % 16;
					if (Math.abs(rem) > 15) {
						hanging = true;
					}
				}
			}
			
		}
		
		public function collideMovingPlatform(Object1:FlxObject, Object2:FlxObject) : void{
			FlxObject.separate(Object1, Object2);
			this.acceleration.x += Object1.velocity.x;
			this.acceleration.y += Object1.velocity.y;
			
			
		}
	
		
	}
	
}