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
		[Embed(source = '../resources/img/bliss.png')]private static var bgImage:Class;
		
		public var bg1 : FlxSprite;
		private var bg2 : FlxSprite;
		
		private var yOffset : int;
		public var bg1pos : FlxPoint;
		
		public function  ScrollingBackground() {
			bg1 = new FlxSprite();
			bg1.y = -100;
			bg1.x = 0;
			bg1.loadGraphic(bgImage);
			bg1.scrollFactor.x = .5;
			bg1.scrollFactor.y = .5;
			
			this.add(bg1);
			
			bg2 = new FlxSprite();
			bg2.y = -100;
			bg2.x = 520;
			bg2.loadGraphic(bgImage);
			bg2.scrollFactor.x = .5;
			bg2.scrollFactor.y = .5;
			
			this.add(bg2);
			
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