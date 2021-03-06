package 
{
	import org.flixel.FlxBasic;
	import org.flixel.FlxGroup;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	import org.flixel.FlxText;
	import org.flixel.FlxG;
	import org.flixel.FlxU;
	import org.flixel.FlxTimer;
	
	/**
	 * ...
	 * @author ...
	 */
	public class HUD extends FlxGroup
	{
		[Embed(source = '../resources/img/hud.png')]private static var trangleImage:Class;
		
		private var worldRef : World;
		private var player : Player;
		private var txtBlockWidth : int = 400;
		
		private var score : int;
		private var scoreText : FlxText;
		private var levelText : FlxText;
		private var coinsText : FlxText;
		private var timerText : FlxText;
		private var levelCompleteText : FlxText;
		
		private static var leftMargin : int = 100;
		private static var rightMargin : int = 100;
		private static var bottomMargin : int = 5;
		
		private var playerIndicator : FlxSprite;
		private var chaseIndicator : FlxSprite;
		
		
		public function HUD(wRef : World) {
			
			worldRef = wRef;
			player = wRef.player;
			
			coinsText = new FlxText(CommonConstants.WINDOWWIDTH / 2 - 200, 0, 200);
			coinsText.alignment = "right";
			add(coinsText);
			
			scoreText = new FlxText(CommonConstants.WINDOWWIDTH / 4 - 100, 0, 199);
			scoreText.alignment = "center";
			add(scoreText);
			
			levelText = new FlxText(0, 0, 200);
			levelText.alignment = "left";
			levelText.text = "0";
			add(levelText);
			
			timerText = new FlxText(CommonConstants.WINDOWWIDTH / 4 - 100, 20, 200);
			timerText.text = "0";
			timerText.alignment = "center";
			//add(timerText);
			
			//progress bar @ bottom:
			var bottomLine : FlxSprite = new FlxSprite(leftMargin, CommonConstants.WINDOWHEIGHT / 2 - bottomMargin);
			bottomLine.makeGraphic(CommonConstants.WINDOWWIDTH / 2 - leftMargin - rightMargin, 2, 0xff999999);
			add(bottomLine);
			
			playerIndicator = new FlxSprite(CommonConstants.WINDOWWIDTH / 4, CommonConstants.WINDOWHEIGHT / 2 - 2 * bottomMargin - 5);
			playerIndicator.loadGraphic(trangleImage, true, false, 16, 16);
			//playerIndicator.offset.x -= player.width / 2;
			playerIndicator.color = 0xFF0000FF;
			playerIndicator.x = CommonConstants.VISIBLEWIDTH - rightMargin - playerIndicator.width;
			
			add(playerIndicator);
			
			
			
			chaseIndicator = new FlxSprite(leftMargin, CommonConstants.WINDOWHEIGHT / 2 - 2 * bottomMargin - 5);
			chaseIndicator.loadGraphic(trangleImage, true, false, 16, 16);
			chaseIndicator.color = 0xFF00FF00;

			add(chaseIndicator);
		}
		
		public function DisplayCenteredText(text : String) : FlxText {
			
			var txt : FlxText = new FlxText(0, 0, txtBlockWidth, text);
			txt.size = 20;
			txt.alignment = "center";
			//txt.centerOffsets();
			
			
			txt.x = CommonConstants.WINDOWWIDTH / 4 - txtBlockWidth / 2;
			txt.y = CommonConstants.WINDOWHEIGHT / 4;
			
			add(txt);
			return txt;
		}
		
		public function DisplayLevelComplete() : void {
			levelCompleteText = DisplayCenteredText("Level Complete");
		}
		
		public function RemoveLevelComplete() : void {
			levelCompleteText.kill();
			levelCompleteText = null;
		}
		
		override public function update() : void {
			var newTime : int = FlxU.getTicks();
			
			timerText.text = FlxU.formatTicks(0, newTime);

			coinsText.text = "Orbs \n   " + player.collectiblesCollected.toString();
			scoreText.text = "Score \n " + player.score;
			levelText.text = "Level \n" + (FlxG.state as PlayState).world.currentLevel.toString();
			
			var playerGain : Number = player.x - worldRef.monsterX;
			var barScale : Number = World.levelWidth * CommonConstants.TILEWIDTH
			
			if (playerGain > barScale) {
				chaseIndicator.x = leftMargin; // CommonConstants.VISIBLEWIDTH - rightMargin - playerIndicator.width;
			}
			else if (playerGain <= 0) {
				chaseIndicator.x = CommonConstants.VISIBLEWIDTH - rightMargin - chaseIndicator.width;
			}
			else {
				var targetX : int = (1 - playerGain / barScale) * (CommonConstants.VISIBLEWIDTH - rightMargin - chaseIndicator.width - leftMargin) + leftMargin;
				chaseIndicator.x = targetX;
			}
			
			
			super.update();
		}
		
		override public function add(obj : FlxBasic) : FlxBasic {
			if (obj is FlxSprite) {
				var sprite:FlxSprite = obj as FlxSprite;
				sprite.scrollFactor.x = 0;
				sprite.scrollFactor.y = 0;
				return super.add(sprite);
			}
			else {
				return super.add(obj);
			}
		}
	
	}
}