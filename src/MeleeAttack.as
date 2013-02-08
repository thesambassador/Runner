package  
{
	import org.flixel.FlxSprite;
	import org.flixel.FlxG;
	/**
	 * ...
	 * @author ...
	 */
	public class MeleeAttack extends FlxSprite 
	{
		
		[Embed(source = '../resources/img/slash.png')]private static var projectileSprites:Class;
		
		public var parent : FlxSprite;
		public var delay : int = 20;
		public var cur : int = 0;
		public var aliveT : int = 0;
		
		public var xOffset : Number = 16;
		public var yOffset : Number = 0;
		
		public function MeleeAttack(startX : Number, startY : Number, parentSprite : FlxSprite) 
		{
			super(startX, startY);
			super.loadGraphic(projectileSprites, true, true, 32, 32);
			
			parent = parentSprite;
			
			FlxG.watch(this, "cur", "Cur");
			FlxG.watch(this, "finished", "Finished");
			FlxG.watch(this, "aliveT", "Alive");
			
			this.addAnimation("animate", new Array(0, 1, 2, 3, 4, 5, 6), 30);
		}
		
		override public function update() : void {
			aliveT ++;
			
			if (cur == delay) {
				this.play("animate");
				this.x = parent.x + xOffset;
				this.y = parent.y + yOffset;
			}
			
			if (cur < delay) {
				cur ++;
				this.x = -500;
				this.y = -500;
				
			}
			else {
				this.velocity.x = this.parent.velocity.x;
				this.velocity.y = this.parent.velocity.y;
				
				if (this.finished) {
					this.kill();
				}
			}
			
			

			
			
			super.update();
		}
	}

}