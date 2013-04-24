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
		
		public var stars : FlxSprite;
		public var bg1 : FlxSprite;
		public var bg2 : FlxSprite;
		
		private var yOffset : int;
		public var bg2pos : FlxPoint;
		
		public function ScrollingBackground() {
			stars = new FlxSprite(0,0);
			stars.makeGraphic(CommonConstants.WINDOWWIDTH / 2, CommonConstants.WINDOWHEIGHT / 2, 0xFF000000);
			var numStars : int = 250;
			for (var i : int = 0; i < numStars; i++) {
				var x : int = CommonFunctions.getRandom(0, CommonConstants.WINDOWWIDTH / 2);
				var y : int = CommonFunctions.getRandom(0, CommonConstants.WINDOWHEIGHT / 2);
				stars.framePixels.setPixel(x, y, 0xFFFFFF);
			}
			stars.scrollFactor.x = 0;
			stars.scrollFactor.y = 0;
			add(stars);
			
			
			
			bg1 = new FlxSprite();
			bg1.y = 0;
			bg1.x = 0;
			bg1.loadGraphic(bgImage);
			bg1.scrollFactor.x = .05;
			bg1.scrollFactor.y = 0;
			
			bg2 = new FlxSprite();
			bg2.loadGraphic(bgImage);
			bg2.y = 0;
			bg2.x = bg2.width;
			bg2.scrollFactor.x = .05;
			bg2.scrollFactor.y = 0;
			
			this.add(bg1);
			this.add(bg2);
			
			//var scaleFactor : FlxPoint = new FlxPoint(8, 8);
			//bg1.scale(scaleFactor);

		}
		
		override public function update():void 
		{
			
			this.bg2.getScreenXY(bg2pos);
			if (!bg1.onScreen()) {
				bg1.x = bg2.x + bg2.width;
				var bgswitch : FlxSprite = bg1;
				bg1 = bg2;
				bg2 = bgswitch;
			}
		
			
			super.update();
		}
		
		
	}
	
}