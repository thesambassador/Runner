package 
{
	import org.flixel.FlxGroup;
	import org.flixel.FlxSprite;
	import org.flixel.FlxPoint;
	import org.flixel.FlxG;
	
	/**
	 * ...
	 * @author ...
	 */
	public class ScrollingBackground extends FlxGroup 
	{
		[Embed(source = '../resources/img/background.png')]private static var bgImage:Class;
		
		public var bg1 : FlxSprite;
		private var bg2 : FlxSprite;
		
		private var yOffset : int;
		public var bg1pos : FlxPoint;
		
		public function ScrollingBackground() {
			bg1 = new FlxSprite();
			bg1.y = -200;
			bg1.x = 0;
			bg1.loadGraphic(bgImage);
			bg1.scrollFactor.x = .25;
			bg1.scrollFactor.y = .25;
			
			this.add(bg1);
			
			//var scaleFactor : FlxPoint = new FlxPoint(8, 8);
			//bg1.scale(scaleFactor);
			
			bg1pos = new FlxPoint();
			
			FlxG.watch(this.bg1pos, "x", "bg1 X");
		}
		
		override public function update():void 
		{
			
			this.bg1.getScreenXY(bg1pos);
			super.update();
		}
		
		
	}
	
}