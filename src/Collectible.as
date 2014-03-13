package 
{
	import org.flixel.FlxSprite;
	import org.flixel.FlxSound;
	import org.flixel.FlxG;
	import org.flixel.FlxEmitter;
	import org.flixel.FlxParticle;
	
	/**
	 * ...
	 * @author ...
	 */
	public class Collectible extends Entity 
	{
		[Embed(source = '../resources/img/collectible.png')]private static var collectibleImage:Class;
		
		public function Collectible(startX:int = 0, startY:int = 0) 
		{
			super(startX, startY);
			super.loadGraphic(collectibleImage, true, false, 16, 16);
			
			this.addAnimation("pulse", [1, 2, 3, 2, 1], 4);
			this.play("pulse");
		}
		
		override public function collidePlayer(playerObj:Player) : void {
			if(this.exists){
				playerObj.collectCollectible(this);
				
				//this.EmitParticles();
				this.kill();
			}
		}
		
		public function EmitParticles() : void{
			var emitter : FlxEmitter = new FlxEmitter(0,0);
			emitter.at(this);
			
			
			for (var i:int = 0; i < 20; i++){
				emitter.add(deathParticle);
				var deathParticle : FlxParticle = new FlxParticle();
			
				deathParticle.makeGraphic(2, 2, 0xffffffff);
				deathParticle.exists = false;
			}
			
			emitter.gravity = 0;
			emitter.setSize(15, 16);
			
			emitter.minParticleSpeed.y = -25;
			emitter.maxParticleSpeed.y = 25;
			emitter.maxParticleSpeed.x = 25;
			emitter.minParticleSpeed.x = -25;
			
			(FlxG.state as PlayState).world.particles.add(emitter)
			emitter.start(true, 1, 1, 0);
		}
	
			
	}
	
}