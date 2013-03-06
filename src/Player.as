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
		[Embed(source = '../resources/img/aliensprites.png')]private static var playerSprites:Class;

	
		private var controlConfig : Dictionary;
		
		public var rem : Number;
		
		private var tilemapRef : FlxGroup;
		
		//movement constants:
		private var groundDragFactor : Number = 6;
		private var airDragFactor : Number = 3;
		private var gravity : Number = 1000;
		
		private var walkSpeed:Number = 160;
		private var runSpeed:Number = 250;
		private var minSlideSpeed:Number = 100;
		private var accelerationFactor:Number = 2;
		
		private var jumpTime:Number = 7;  //variable for how long you can hold down the jump button and get lift
		private var jumpVel:Number = 260.00;
		private var jumpEnergy:Number = jumpTime;
		public var canStand:Boolean = true; //hack job... too tired to figure out an elegant way, and this is quick, simple, and dirty.
		
		//state stuff
		public var state:String = "ground";
		public var lastState:String = ""; //this is the state that was active on the last frame.  
		public var attacking:Boolean = false; //is the character currently attacking?
		public var attackCooldown : int = 25; //cooldown before you can do another attack
		public var attackReady : int = 0; //current readiness of the attack... gets set to attackCooldown right when you attack.
		public var attackProjectile : MeleeAttack;
		
		public var totalFrames : int = 0;
		
		public var lastVel : FlxPoint;
		
		public var currentAnimationPriority : int = 0; //currently playing animation's priority, if I play something with a higher priority it will override

		public function Player(xStart:int = 0, yStart:int = 0, tmRef : FlxGroup = null){
			super(xStart, yStart);
			
			this.tilemapRef = tmRef;
			
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
			this.loadGraphic(playerSprites, true, true, 32, 32);
			//this.frames = 4;
			this.frameWidth = 32;
			this.frameHeight = 32;
			this.offset.x += 8; //offset since sprite is 32x32 but character is 16x32
			
			//animation
			this.addAnimation("run", new Array(11, 12, 13, 12), 10);
			this.addAnimation("startrun", new Array(8, 9, 10), 15, false);
			this.addAnimation("idle", new Array(0, 1, 2, 3, 4, 5), 8);
			this.addAnimation("jump", new Array(16, 17, 18), 20, false);
			this.addAnimation("fallinit", new Array(19, 20, 21, 22), 10, false);
			this.addAnimation("fall", new Array(22, 23), 5);
			this.addAnimation("landlight", new Array(34, 34, 35), 20, false);
			this.addAnimation("landheavy", new Array(32, 33 ,34, 35), 20, false);
			this.addAnimation("slow", new Array(14, 14));
			this.addAnimation("startslide", new Array(24, 25, 26, 27), 30, false);
			this.addAnimation("endslide", new Array(27, 26, 25, 24), 30, false);
			this.addAnimation("slide", new Array(27, 27));
			
			this.width = 15; //so we can still fall between 2 tiles with a 1 space gap
			
			FlxG.watch(this.velocity, "x", "Vel X");
			FlxG.watch(this.velocity, "y", "Vel Y");
			FlxG.watch(this, "state", "State");
		}
		
		override public function update():void 
		{
			
			totalFrames ++;
			//reset acceleration and apply gravity
			this.acceleration.x = 0;
			this.acceleration.y = gravity;
			
			//some variables to keep track of things?  not sure if needed anymore
			
			//save the last frame's state
			lastState = state;
			
			//reset animation priority if no animation is currently playing:
			if (this.finished) {
				this.currentAnimationPriority = 0;
			}
			
			//states are: ground, air, sliding, levelend
			//the states themselves will handle the transitions to the other states
			//In the case that a state decides to transition to another one, it will run that state's update right away (this frame) instead of the next one.
			//The state update functions return true if they actually ran and did their update, or false if they triggered a state change.
			var didUpdate : Boolean = false;
			while(!didUpdate){
				switch(state) {
					case "ground":
						didUpdate = updateGroundState();
						break;
					case "air":
						didUpdate = updateAirState();
						break;
					case "slide":
						didUpdate = updateSlideState();
						break;
					case "levelend":
						didUpdate = updateLevelEndState();
						break;
				}
			}
			
			this.velocity.copyTo(lastVel);
			
			canStand = true;
			
			super.update();
		}
		
		//ground state can transition to air (by jumping or running off an edge) or to sliding.
		private function updateGroundState () : Boolean {
			
			if (!this.isTouching(FlxObject.FLOOR)) {
				changeState("air");
				return false;
			}
			
			if (FlxG.keys[controlConfig["DOWN"]] && !this.isTouching(FlxObject.WALL)) {
				this.changeState("slide");
				return false;
			}
			
			if (FlxG.keys.justPressed(controlConfig["JUMP"])) {
				jumpEnergy = jumpTime; 
				this.velocity.y = -jumpVel / 1.5;
				changeState("air");
				return false;
			}
			
			this.drag.x = this.maxVelocity.x * groundDragFactor; //drag factor for standing on the ground
			
			//respond to input and set speed/acceleration
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

			//check to see if we're accelerating in the opposite direction that we're moving in (trying to turn around).  If we are, help us slow down a bit.
			if (this.acceleration.x * this.velocity.x < 0) {
				this.playPriority("slow", 8);
				this.acceleration.x *= 2
			}
			
			//check our current velocity for animation stuff
			if (Math.abs(this.velocity.x) > 0) {
				if (this._curAnim != null) {
					if (this._curAnim.name == "idle") {
						this.playPriority("startrun", 4);
					}
					//else if (this._curAnim.name == "startrun" && !this.finished) {
					//}
					else {
						this.playPriority("run", 3);
					}
				}
			}
			
			else {
				this.playPriority("idle", 0);
			}
			
			return true;
		}
		
		//air state can transition to the ground state, obviously, and that's pretty much it.
		private function updateAirState () : Boolean {
			//if we're on the ground, and our y velocity isn't negative (up), go back to ground.
			if (this.isTouching(FlxObject.FLOOR) && velocity.y >= 0) {
				if (lastVel.y > 400)
					this.playPriority("landheavy", 5);
				else
					this.playPriority("landlight", 5);
				changeState("ground");
				return false;
			}
			
			//jumping stuff
			if (FlxG.keys[controlConfig["JUMP"]]) { //if we've been holding down jump in the air from jumping
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
				if (FlxG.keys.justReleased(controlConfig["JUMP"]))
					this.velocity.y *= .75;
				jumpEnergy = 0; //if we're in the air and jump isn't being pressed, we reset our jump energy.
			}
			
			//respond to input and set speed/acceleration
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
			
			
			//air animation stuff
			this.drag.x = this.maxVelocity.x * airDragFactor;
			
			if (this.velocity.y < 0) {
				if(this.jumpEnergy > this.jumpTime - 2)
					this.playPriority("jump", 6);
			}
			else {
				if(this.velocity.y * this.lastVel.y < 0){ //if our velocity has changed and we're falling, play fallinit once.
					this.playPriority("fallinit", 4);
				}
				else{
					this.playPriority("fall", 1);
				}
			}
			return true;
		}
		
		//slide can only transition to the ground state, which will transition to the air state when it sees it's not on the ground.
		private function updateSlideState () : Boolean {
			this.setBoundHeight(15);
			if (state != lastState) {
				this.playPriority("startslide", 6);
			}

			if (!FlxG.keys[controlConfig["DOWN"]] || !this.isTouching(FlxObject.FLOOR)) {
				if (canStand) {
					changeState("ground");
					this.playPriority("endslide", 6);
					this.setBoundHeight(31);
					return true;
				}

				else {
					if (Math.abs(this.velocity.x) < minSlideSpeed) {
						var dir = 1;
						if (this.facing == FlxObject.LEFT) dir = -1;
						
						this.velocity.x = minSlideSpeed * dir;
					}
				}
			}
			
			this.drag.x = this.maxVelocity.x * 1; //less drag for sliding... weeee
			
			this.playPriority("slide", 1);

			return true;
		}
		
		private function updateLevelEndState () : Boolean {
			return true;
		}
		
		public function calcCanStand(collided : FlxTilemap) : Boolean {
			var overheadPointL : FlxPoint = new FlxPoint(this.x, this.y + this.height - 18);
			var overheadPointR : FlxPoint = new FlxPoint(this.x + 14, this.y + this.height - 18);
			
			try{
				if (collided.overlapsPoint(overheadPointL) || collided.overlapsPoint(overheadPointR)) {
					return false;
				}
			}
			catch (e:Error) {
				
			}
			return true;
		}
		
		private function changeState(newState:String) : void {
			if (newState != state) {
				state = newState;
			}
		}
		
		
		private function updateAttacking() : void {
			if (attackReady > 0) attackReady --;
		
			
			//ATTACK
			//if(!sliding){
				if (FlxG.keys.justPressed(controlConfig["RUN"]) && attackReady == 0) {
					attackReady = attackCooldown;
					attackProjectile = new MeleeAttack(this.x + 20, this.y, this);
					attackProjectile.facing = this.facing;
					FlxG.state.add(attackProjectile);
				}
			//}
		}
		
		public function playPriority(name:String, priority:int) {
			if (priority >= currentAnimationPriority) {
				this.play(name); 
				currentAnimationPriority = priority
			}
		}
		
		public function setBoundHeight(h:int) : void {
			this.y += this.height - h;
			this.height = h;

			this.offset.y = 32 - this.height;
		}
		
		public function getFocusPoint() : FlxPoint {
			var returned : FlxPoint = new FlxPoint();
			
			var yOffset : Number = 0;
			if (this.state == "slide")
				yOffset = 16;
			
			returned.x = this.x;
			returned.y = this.y - yOffset;
			
			return returned;
		}
		
		public function collideTilemap(tilemap:FlxObject, playerObj:FlxObject) : Boolean{
			
			var player : Player = playerObj as Player;
			
			var originalPosX : Number = player.x;
			var originalPosY : Number = player.y;

			var returned : Boolean = FlxObject.separate(tilemap, player);

			if(player.canStand){
				player.canStand = player.calcCanStand(tilemap as FlxTilemap);
			}
			
			
			return returned;
		}
		
		public function collideMovingPlatform(Object1:FlxObject, Object2:FlxObject) : void{
			FlxObject.separate(Object1, Object2);
			this.acceleration.x += Object1.velocity.x;
			this.acceleration.y += Object1.velocity.y;
			
			
		}
	
		
	}
	
}