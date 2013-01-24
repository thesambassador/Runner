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
		
		public function MeleeAttack(startX : Number, startY : Number, parentSprite : FlxSprite) 
		{
			super(startX, startY);
			super.loadGraphic(projectileSprites, true, true, 32, 32);
			
			parent = parentSprite;
			
			
			
			this.addAnimation("animate", new Array(0, 1, 2, 3, 4, 5, 6), 30);
		}
		
		override public function update() : void {
			
			this.velocity.x = this.parent.velocity.x;
			this.velocity.y = this.parent.velocity.y;

			
			this.play("animate");
			if (this.finished) {
				this.kill();
			}
			super.update();
		}
	}

}