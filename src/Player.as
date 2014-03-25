package 
{
	import flash.geom.ColorTransform;
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
		[Embed(source = '../resources/sound/jump.mp3')]private static var jumpSound:Class;
		[Embed(source = '../resources/sound/respawn.mp3')]private static var respawnSound:Class;
		[Embed(source = '../resources/sound/playerDeath.mp3')]private static var deathSound:Class;
		[Embed(source = '../resources/sound/slide.mp3')]private static var slideSound:Class;
		
		[Embed(source = '../resources/sound/pickup1.mp3')]private static var pickupSound1:Class;
		[Embed(source = '../resources/sound/pickup2.mp3')]private static var pickupSound2:Class;
		[Embed(source = '../resources/sound/pickup3.mp3')]private static var pickupSound3:Class;
		[Embed(source = '../resources/sound/pickup4.mp3')]private static var pickupSound4:Class;
		
		public var soundSlide : FlxSound;
		
		public var pickupSounds : Array;
		public var pickupSoundIndex : int = 0;
		public var pickupSoundDelay : int = 60;

		
		private var controlConfig : Dictionary;
		
		public var collectiblesCollected : int = 0;
		public var collectiblesCollectedLevel : int = 0;
		public var enemiesKilled : int = 0;
		public var enemiesKilledLevel : int = 0;
		public var score : int = 0;
		public var level : int = 0;
		public var invulnerable : int = 0; //how many frames to be invulnerable
	
		public var lives : int = 2;
		
		//movement constants:
		private var groundDragFactor : Number = 4;
		private var airDragFactor : Number = 3;
		private var gravity : Number = 1000;
		
		private var walkSpeed:Number = 250;
		public var runSpeed:Number = 300;
		public var minSlideSpeed:Number = 100;
		private var accelerationFactor:Number = 2;
		
		private var airTime: int = 0;
		private var jumpTime:Number = 7;  //variable for how long you can hold down the jump button and get lift
		private var jumpVel:Number = 270.00;
		private var jumpEnergy:Number = jumpTime;
		public var canStand:Boolean = true; //hack job... too tired to figure out an elegant way, and this is quick, simple, and dirty.
		
		//state stuff
		public var state:String = "menu";
		public var lastState:String = ""; //this is the state that was active on the last frame.  
		
		public var lastVel : FlxPoint;
		public var lastPos : FlxPoint;
		
		public var currentAnimationPriority : int = 0; //currently playing animation's priority, if I play something with a higher priority it will override
		
		public var playerEffect : PlayerEffects;
		public var currentPlatform : MovingPlatform;
		
		public var invulnFlashValue : Number = 0;
		public var invulnFlashDirection : Number = .1;
		
		public var deathCount : int = 0;
		public var deathCountLevel : int = 0;
		
		public var springboardCount : int = 0;
		public var levelAirTime : Number = 0;
		public var levelRunDist : Number = 0;
		public var levelSlideDist : Number = 0;
		public var consecutiveEnemies : Number = 0;
		

		public function Player(xStart:int = 0, yStart:int = 0){
			super(xStart, yStart);
			
			//controls:
			controlConfig = new Dictionary();
			controlConfig["LEFT"] = "LEFT";
			controlConfig["RIGHT"] = "RIGHT";
			controlConfig["UP"] = "UP";
			controlConfig["DOWN"] = "DOWN";
			controlConfig["JUMP"] = "SPACE";
			controlConfig["RUN"] = "SHIFT";
			
			//movement
			this.maxVelocity.x = walkSpeed;
			this.maxVelocity.y = 700;
			this.acceleration.y = 1000;
			this.drag.x = this.maxVelocity.x * 3;
			this.lastVel = new FlxPoint();
			this.lastPos = new FlxPoint();
			
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
			this.addAnimation("frozen", new Array(0, 0), 8);
			this.addAnimation("jump", new Array(16, 17, 18), 20, false);
			this.addAnimation("fallinit", new Array(19, 20, 21, 22), 10, false);
			this.addAnimation("fall", new Array(22, 23), 5);
			this.addAnimation("landlight", new Array(34, 34, 35), 20, false);
			this.addAnimation("landheavy", new Array(32, 33 ,34, 35), 20, false);
			this.addAnimation("slow", new Array(14, 14));
			this.addAnimation("startslide", new Array(24, 25, 26, 27), 30, false);
			this.addAnimation("endslide", new Array(27, 26, 25, 24), 30, false);
			this.addAnimation("slide", new Array(27, 27));
			this.addAnimation("invis", new Array(63, 63));
			
			this.width = 15; //so we can still fall between 2 tiles with a 1 space gap
			
			FlxG.watch(this, "levelRunDist", "RunDist");
			FlxG.watch(this, "levelAirTime", "AirTime");
			
			pickupSounds = new Array();
			pickupSounds.push(pickupSound4);
			pickupSounds.push(pickupSound3);
			pickupSounds.push(pickupSound2);
			pickupSounds.push(pickupSound1);
			
			soundSlide = FlxG.loadSound(slideSound);
		
		}
		
		override public function update():void 
		{
			if (FlxG.keys.justPressed("K")) this.health = 0;
			
			if (alive && health <= 0) {
				kill();
			}
			
			if (invulnerable > 0) {
				invulnerable -= 1;
				invulnFlashValue += invulnFlashDirection;
				
				_colorTransform = new ColorTransform();
				_colorTransform.blueOffset = 255 * invulnFlashValue;
				_colorTransform.redOffset = 255 * invulnFlashValue;
				_colorTransform.greenOffset = 255 * invulnFlashValue;
				
				if (invulnFlashValue <= 0) {
					invulnFlashDirection = .05;
				}
				else if(invulnFlashValue >= 1){
					invulnFlashDirection = -.05;
				}
				
				
			}
			else {
				alpha = 1;
				_colorTransform = null;
			}
			
			//reset acceleration and apply gravity
			this.acceleration.x = 0;
			this.acceleration.y = gravity;
			
			if(pickupSoundDelay > 0){
				pickupSoundDelay --;
			}
			else {
				pickupSoundIndex = 0;
			}
			
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
					case "levelEnd":
						didUpdate = updateLevelEndState();
						break;
					case "respawn":
						didUpdate = updateRespawn();
						break;
					case "menu":
						didUpdate = updateMenu();
						
				}
			}
			
			this.velocity.copyTo(lastVel);
			this.lastPos.x = this.x;
			this.lastPos.y = this.y;
			
			canStand = true;
			
			if (playerEffect != null) {
				playerEffect.update();
			}
			
			super.update();
		}
		
		override public function draw() : void {
			super.draw();
			if (playerEffect != null) {
				playerEffect.draw();
			}
		}
		
		override public function preUpdate() : void {
			super.preUpdate();
			if (playerEffect != null) {
				playerEffect.preUpdate();
			}
		}
		
		override public function postUpdate() : void {
			super.postUpdate();
			if (playerEffect != null) {
				playerEffect.postUpdate();
			}
		}
		
		override public function kill() : void {
			super.kill();
			this.health = 0;
			this.invulnerable = 60;
			FlxG.play(deathSound);
			FlxG.state.add(PlayerEffects.deathByFire(this.x, this.y, playerSprites));
			
			deathCount ++;
			deathCountLevel ++;
		}
		
		override public function reset(X:Number, Y:Number) : void {
			super.reset(X, Y);
			FlxG.state.add(PlayerEffects.respawn(this.x, this.y, playerSprites));
			this.playPriority("invis", 10);
			
			var visibleTimer : FlxTimer = new FlxTimer();
			visibleTimer.start(1, 1, makeVisible);
			
			var respawnTimer : FlxTimer = new FlxTimer();
			respawnTimer.start(1, 1, finishRespawn);
			
			//this.visible = false;
			FlxG.play(respawnSound);
			changeState("respawn");
			//this.collectiblesCollected = 0;
		}
		
		private function updateMenu() : Boolean {
			this.playPriority("idle", 20);
			return true;
		}
		
		//ground state can transition to air (by jumping or running off an edge) or to sliding.
		private function updateGroundState () : Boolean {
			airTime = 0;
			consecutiveEnemies = 0;
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
				FlxG.play(jumpSound);
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
			
			levelRunDist +=  Math.abs(this.x - this.lastPos.x);
			
			
			return true;
			
		}
		
		override public function hurt(damage : Number) : void{
			if (invulnerable == 0 && state != "levelEnd") super.hurt(damage);
		}
		
		

		
		//air state can transition to the ground state, obviously, and that's pretty much it.
		private function updateAirState () : Boolean {
			airTime ++;
			
			//let ourselves still jump a bit after we run off a ledge to be a bit mroe forgiving
			if (airTime <= 4) {
				if (FlxG.keys.justPressed(controlConfig["JUMP"]) && canStand) {
					jumpEnergy = jumpTime; 
					this.velocity.y = -jumpVel / 1.5;
				}
			}
			
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
				else {
					//this.playPriority("fallinit", 4);
				}
			}
			else {
				if(this.velocity.y * this.lastVel.y < 0){ //if our velocity has changed and we're falling, play fallinit once.
					this.playPriority("fallinit", 4);
				}
				else {
					if(this._curAnim != null && this._curAnim.name != "fallinit")
						this.playPriority("fall", 1);
				}
			}
			
			levelAirTime += FlxG.elapsed;
			return true;
		}
		
		//slide can only transition to the ground state, which will transition to the air state when it sees it's not on the ground.
		private function updateSlideState () : Boolean {
			this.setBoundHeight(15);
			
			if (state != lastState) {
				this.playPriority("startslide", 6);
			}
			
			if (FlxG.keys.justPressed(controlConfig["JUMP"]) && canStand) {
				this.setBoundHeight(31);
				this.y -= 2;
				jumpEnergy = jumpTime; 
				this.velocity.y = -jumpVel / 1.5;
				changeState("air");
				return false;
			}

			if (!FlxG.keys[controlConfig["DOWN"]] || !this.isTouching(FlxObject.FLOOR)) {
				if (canStand) {
					changeState("ground");
					this.playPriority("endslide", 6);
					this.setBoundHeight(31);
					this.y -= 2;
					this.x -= 1; //hack to fix getting pushed underground
					return false;
				}

				else {
					if (Math.abs(this.velocity.x) < minSlideSpeed) {
						var dir : int = 1;
						if (this.facing == FlxObject.LEFT) dir = -1;
						
						this.velocity.x = minSlideSpeed * dir;
					}
				}
			}
			
			this.drag.x = this.maxVelocity.x * 1; //less drag for sliding... weeee
			
			if (Math.abs(this.velocity.x) > 30) {
				soundSlide.play();
			}
			
			this.playPriority("slide", 1);
			
			levelSlideDist +=   Math.abs(this.x - this.lastPos.x);
			
			return true;
		}
		
		private function updateLevelEndState () : Boolean {
			this.playPriority("run", 3);
			this.facing = FlxObject.RIGHT;
			this.acceleration.x = this.maxVelocity.x * accelerationFactor;
			return true;
		}
		
		private function updateRespawn() : Boolean {
			this.invulnerable = 240;
			
		
			return true;
		}
		
		public function makeVisible(poop:FlxTimer) : void {
			this.playPriority("frozen", 11);
		}
		
		public function finishRespawn(poop:FlxTimer) : void {
			this.setBoundHeight(31);
			changeState("ground");
		}
		
		private function changeState(newState:String) : void {
			if (newState != state) {
				state = newState;
			}
		}
		
		
		public function playPriority(name:String, priority:int) : void {
			if (priority >= currentAnimationPriority) {
				this.play(name); 
				currentAnimationPriority = priority;
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
		
		
		
		
		public function Bounce(small : int, big : int) : void {
			if(FlxG.keys[controlConfig["JUMP"]])
				this.velocity.y = big;
			else
				this.velocity.y = small;
			this.playPriority("jump", 6);
			
			//if we bounce on an enemy
			if (big == -400) {
				consecutiveEnemies += 1;
				if (consecutiveEnemies >= 3) {
					MissionManager.SetValue("enemyBounce", 1);
				}
			}
		}
		
		public function collectCollectible(c : Collectible) : void {
			FlxG.play(pickupSounds[pickupSoundIndex] as Class);
			if (pickupSoundIndex < pickupSounds.length - 1) pickupSoundIndex ++;
			pickupSoundDelay = 60;
			addScore(100);
			this.collectiblesCollected ++ ;
			this.collectiblesCollectedLevel ++ ;
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
		
		public function addScore(amount : int) : void {
			score += amount;
		}
		
		public function calcCanStand(collided : FlxTilemap) : Boolean {
			
			
			var overheadPointL : FlxPoint = new FlxPoint(this.x, this.y + this.height - 18);
			var overheadPointR : FlxPoint = new FlxPoint(this.x + this.width - 1, this.y + this.height - 18);
			
			var overheadPointFuture : FlxPoint = new FlxPoint(this.x + this.width + this.velocity.x * (1/60), this.y + this.height - 18);
			
			//var overheadPointVel : FlxPoint = new FlxPoint(this.x + 14 + this.velocity.x, this.y + this.height - 18);
			
			try{
				if (collided.overlapsPoint(overheadPointL) || collided.overlapsPoint(overheadPointR)) {
					return false;
					
				}
				if (this.velocity.x != 0) {
					if (collided.overlapsPoint(overheadPointFuture)) {
						return false;
					}
				}
			}
			catch (e:Error) {
				
			}
			return true;
		}
		
		public function collideMovingPlatform(Object1:FlxObject, Object2:FlxObject) : void{
			FlxObject.separate(Object1, Object2);
			this.acceleration.x += Object1.velocity.x;
			this.acceleration.y += Object1.velocity.y;
			
			
		}
	
		
	}
	
}