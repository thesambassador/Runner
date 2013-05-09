package 
{
	import org.flixel.FlxPath;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	import org.flixel.FlxParticle;
	import org.flixel.FlxEmitter;
	import org.flixel.FlxG;
	import org.flixel.FlxU;
	
	/**
	 * ...
	 * @author Sam Tregillus
	 */
	public class PlayerEffects extends FlxSprite
	{
		public var emitter : FlxEmitter;
		
		public var updateFunction : Function;
		
		public var effectDone : Boolean = true;
		public var playerVisible : Boolean = true;
		
		public var startTime : Number;
		
		public function PlayerEffects(playerSprites : Class, type:String) {
			startTime = 0;
			super();
			//graphics
			this.loadGraphic(playerSprites, true, true, 32, 32);
			this.solid = false;
			this.visible = false;
			//this.frames = 4;
			this.frameWidth = 32;
			this.frameHeight = 32;
			
			this.addAnimation("respawn", new Array(55, 54, 53, 52, 51, 50, 49, 48, 47, 46, 45, 44, 43, 42, 41, 40), 16, false);
			this.addAnimation("disappear", new Array(40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55), 24, false);
			
			this.offset.x += 8; //offset since sprite is 32x32 but character is 16x32
			//this.offset.y += this.height / 2; //offset since sprite is 32x32 but character is 16x32
			
			switch(type) {
				case "respawn":
					this.updateFunction = this.respawnUpdate;
					break;
				case "deathByFire":
					this.updateFunction = this.deathByFireUpdate;
					break;
			}
		}
		
		public static function respawn(locX:Number, locY:Number, sprites : Class) : PlayerEffects{
			
			var returned : PlayerEffects = new PlayerEffects(sprites, "respawn");
			
			returned.play("respawn");
			returned.effectDone = false;
			returned.playerVisible = false;
			
			returned.alpha = 1;
			returned.visible = true;
			returned.x = locX;
			returned.y = locY;
			
			returned.emitter = new FlxEmitter(0,0);
			returned.emitter.setSize(16, 1);
			
			returned.emitter.at(returned);
			returned.emitter.x -= 8;
			returned.emitter.y += returned.height / 2;
			returned.emitter.setXSpeed(0, 0);
			returned.emitter.setYSpeed(-50, -40);
			
			for (var i:int = 0; i < 100; i++) {
				var part : FlxParticle = new FlxParticle();
				
				part.makeGraphic(2, 2, 0xffffffff);
				part.exists = false;
				
				returned.emitter.add(part);
			}
			returned.emitter.start(false, 2, .01, 100);
			
			return returned;
		}
		
		public static function deathByFire(locX:Number, locY:Number, sprites : Class) : PlayerEffects {
			var returned : PlayerEffects = new PlayerEffects(sprites, "deathByFire");
			
			returned.play("disappear");
			returned.effectDone = false;
			returned.playerVisible = false;
			
			returned.alpha = 1;
			returned.visible = true;
			returned.color = 0xffee2000;
			returned.x = locX;
			returned.y = locY;
			
			returned.emitter = new FlxEmitter(0,0);
			returned.emitter.setSize(16, 1);
			
			returned.emitter.at(returned);
			returned.emitter.x -= 8;
			returned.emitter.y += returned.height / 2;
			returned.emitter.setXSpeed(-100, 100);
			returned.emitter.setYSpeed(-400, 50);
			returned.emitter.gravity = 1000;
			
			for (var i:int = 0; i < 100; i++) {
				var part : FlxParticle = new FlxParticle();
				
				
				var randColor : uint = FlxU.makeColor(CommonFunctions.getRandom(180, 255), CommonFunctions.getRandom(10, 120), 0);
				
				part.makeGraphic(2, 2, randColor);
				part.exists = false;
				
				returned.emitter.add(part);
			}
			returned.emitter.start(true, 2, .01, 100);
			
			return returned;
		}
		
		public function deathByFireUpdate() : void {
			for each(var particle : FlxParticle in emitter.members) {
				if (particle.exists) {
					particle.alpha -= .02;
				}
			}
			
			emitter.update();
			if (this.finished) {
				this.effectDone = true;
				this.emitter.destroy();
				this.emitter = null;
				this.kill();
			}

		}
		public function respawnUpdate() : void {
			for each(var particle : FlxParticle in emitter.members) {
				if (particle.exists) {
					particle.alpha -= .02;
				}
			}
			
			emitter.update();
			
			if (this.finished && this.alpha > 0) {
				playerVisible = true;
				this.alpha -= 1/30;
			}
			else if (this.alpha <= 0) {
				this.effectDone = true;
				this.updateFunction = null;
				this.emitter.destroy();
				this.emitter = null;
				this.kill();
			}
		}

		override public function update() : void {
			startTime += FlxG.elapsed;
			if (updateFunction != null) {
				updateFunction();
			}
			super.update();
		}
		
		override public function draw() : void {
			if (visible) {
				super.draw();
				if (emitter != null) {
					emitter.draw();
				}
			}
			
		}
	}
	
}