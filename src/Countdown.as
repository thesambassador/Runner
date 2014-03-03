package  
{
	import org.flixel.FlxG;
	import org.flixel.FlxSprite;
	import org.flixel.plugin.photonstorm.FlxDelay;
	/**
	 * ...
	 * @author ...
	 */
	public class Countdown extends FlxSprite
	{
		[Embed(source = '../resources/img/1.png')]private static var img1:Class;
		[Embed(source = '../resources/img/2.png')]private static var img2:Class;
		[Embed(source = '../resources/img/3.png')]private static var img3:Class;
		[Embed(source = '../resources/img/go.png')]private static var imgGo:Class;
		
		public var num : int = 3;
		
		public function Countdown()
		{
			super(0, 0);
			loadGraphic(img3);
			scrollFactor.x = 0;
			scrollFactor.y = 0;
			scale.x = 1.5;
			scale.y = 1.5;
			
			FlxG.shake(.01, .1);
			var timer : FlxDelay = new FlxDelay(1000);
			timer.callback = tick;
			timer.start();
		}
		
		override public function update() : void{
			super.update();
			if(num != 0){
				scale.x -= .02;
				scale.y -= .02;
			}
		}
		
		public function tick() : void {
			num -= 1;
			
			var timer : FlxDelay = new FlxDelay(1000);
			timer.callback = tick;
			FlxG.shake(.01, .1);
			
			if (num == 2) {
				loadGraphic(img2);
				timer.start();
			}
			else if (num == 1) {
				loadGraphic(img1);
				timer.start();
			}
			else if (num == 0){
				loadGraphic(imgGo);
				timer.start();
				this.x = CommonFunctions.alignX(width, "right", 15);
				this.y += 15;
		
			}
			else {
				this.visible = false;
			}
			scale.x = 1.5;
			scale.y = 1.5;
		}
		
	}

}