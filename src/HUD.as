package 
{
	import org.flixel.FlxGroup;
	import org.flixel.FlxPoint;
	import org.flixel.FlxText;
	
	/**
	 * ...
	 * @author ...
	 */
	public class HUD extends FlxGroup
	{
		private var player : Player;
		private var txtBlockWidth : int = 400;
		
		private var score : int;
		private var scoreText : FlxText;
		private var levelCompleteText : FlxText;
		
		public function HUD(playerRef : Player) {
			player = playerRef;
			
			scoreText = new FlxText(CommonConstants.WINDOWWIDTH / 2 - 200, 0, 200);
			scoreText.scrollFactor.x = 0;
			scoreText.scrollFactor.y = 0;
			scoreText.alignment = "right";
			add(scoreText);
		}
		
		public function DisplayCenteredText(text : String) : FlxText {
			
			var txt : FlxText = new FlxText(0, 0, txtBlockWidth, text);
			txt.scrollFactor.x = 0;
			txt.scrollFactor.y = 0;
			txt.size = 20;
			txt.alignment = "center";
			//txt.centerOffsets();
			
			
			txt.x = CommonConstants.WINDOWWIDTH / 4 - txtBlockWidth / 2;
			txt.y = CommonConstants.WINDOWHEIGHT / 4;
			
			add(txt);
			return txt;
		}
		
		public function DisplayLevelComplete() {
			levelCompleteText = DisplayCenteredText("Level Complete");
		}
		
		public function RemoveLevelComplete() {
			levelCompleteText.kill();
			levelCompleteText = null;
		}
		
		override public function update() : void{
			scoreText.text = player.collectiblesCollected;
			super.update();
		}
	
	}
}