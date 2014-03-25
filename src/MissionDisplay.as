package  
{
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxSprite;
	import org.flixel.FlxText;
	import org.flixel.FlxObject;
	/**
	 * ...
	 * @author ...
	 */
	public class MissionDisplay extends FlxGroup
	{
		[Embed(source = '../resources/img/missionSingleBackground.png')]private static var missionBG:Class;
		
		public var missionText : FlxText;
		public var bg : FlxSprite;
		
		public var completed : Boolean;
		public var animationLength : int = 25;
		public var delay : int = 0;
		public var doneAnimating : Boolean = false;
		public var animatedCompleted : Boolean = false;
		
		public var stars : Array;
		
		private var _x : Number = 0;
		private var _y : Number = 0;
		
		public function MissionDisplay(mission : Mission)
		{
			super();
			
			missionText = new FlxText(5, 10, 160, mission.missionDescription);
			
			missionText.scrollFactor.x = 0;
			missionText.scrollFactor.y = 0;
			missionText.size = 8;
			missionText.shadow = FlxG.BLACK;
			
			if (mission.persist) {
				missionText.text += " (" + (mission.goal - mission.progress).toString() + " to go)";
			}
			
			if (missionText.frameHeight > 15) {
				missionText.y -= 7;
			}
			
			bg = new FlxSprite(0, 0);
			bg.loadGraphic(missionBG, true, false, 241, 30);
			bg.scrollFactor.x = 0;
			bg.scrollFactor.y = 0;
			
			bg.addAnimation("complete", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17], 30, false);
			
			add(bg);
			add(missionText);
			
			stars = new Array();
			
			for (var i:int = 1; i <= mission.starValue; i++ ) {
				var star : FlxSprite = new FlxSprite(0, 0, CommonConstants.STARFULL);
				star.scrollFactor.x = 0;
				star.scrollFactor.y = 0;
				
				star.x = bg.width - star.width * i;
				star.y = 1;
				
				add(star);
				stars.push(star);
			}
			
			completed = mission.completed;
		}
		
		public function AnimateCompleted() : void {
			bg.play("complete");
			delay = animationLength;
			doneAnimating = false;
			animatedCompleted = true;
		}
		
		override public function update() : void {
			super.update();
			
			if (delay > 0) delay --;
			else doneAnimating = true;
		}
		
		public function get x () : Number {
			
			return _x;

		}
		
		public function set x (v : Number) : void {
			var diff : Number = v - _x;
			_x = v;
			for each (var object:* in members) {
				if (object is FlxObject) object.x += diff;
			}
		}
		
		public function get y () : Number {
			return _y;
		}
		
		public function set y (v : Number) : void {
			var diff : Number = v - _y;
			_y = v;
			for each (var object:* in members) {
				if (object is FlxObject) object.y += diff;
			}
		}
	}

}