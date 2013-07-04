package  
{
	import flash.geom.Point;
	import org.flixel.FlxBasic;
	import org.flixel.FlxButton;
	import org.flixel.FlxGroup;
	import org.flixel.FlxSprite;
	import org.flixel.FlxText;
	import org.flixel.FlxPoint;
	import org.flixel.FlxG;
	/**
	 * ...
	 * @author Sam Tregillus
	 */
	public class GameOverScreen extends FlxGroup
	{
		public var txtGameOver : FlxText;
		
		public var btnBack : FlxButton;
		public var btnStore : FlxButton;
		public var btnHighscore : FlxButton;
		public var btnPlayAgain : FlxButton;
		
		public var step : int = 0;
		
		private var scoreTextSize : int = 20;
		private var scoreTextWidth : int = 300;
		
		private var leftMargin : int = 20;
		private var rightMargin : int = CommonConstants.VISIBLEWIDTH - 20;
		private var bottomMargin : int = CommonConstants.VISIBLEHEIGHT;
		private var topMargin : int = 20;
		
		private var scoreOverviewY : int = 75;
		private var scoreOverviewX : int = 75;
		
		private var enemiesKilled : int = 0;
		private var coinsCollected : int = 0;
		private var completedLevels : int = 0;
		private var difficultyMult : Number = 1;
		
		private var txtEnemiesKilled : FlxText;
		private var txtcoinsCollected : FlxText;
		private var txtcompletedLevels : FlxText;
		private var txtDifficultyMod : FlxText;
		
		public var playerRef : Player;
		
		private var totalDelay : int = 3;
		private var curDelay : int = 0;
		
		public function GameOverScreen(player : Player) 
		{
			FlxG.mouse.show();
			playerRef = player;
			//game over text
			txtGameOver = new FlxText(0, 0, 400, "Game Over");
			txtGameOver.size = 20;
			txtGameOver.alignment = "center";
			centerVertically(txtGameOver);
			add(txtGameOver);
			
			//bottom buttons
			btnBack = createButton("Main Menu");
			btnBack.x = leftMargin;
			btnBack.y = bottomMargin - 25;
			
			btnStore = createButton("Store");
			centerVertically(btnStore);
			btnStore.y = bottomMargin - 25;
			
			btnHighscore = createButton("High Scores");
			snapRightSideTo(btnHighscore, rightMargin);
			btnHighscore.y = bottomMargin - 25;
			
			add(btnBack);
			add(btnStore);
			add(btnHighscore);
			
			//score overview
			txtEnemiesKilled = new FlxText(0,0,50,"0");
			txtcoinsCollected = new FlxText(0, 0, 50, "0");
			txtcompletedLevels = new FlxText(0, 0, 50, "0");
			txtDifficultyMod = new FlxText(0, 0, 50, "0");
			
			txtEnemiesKilled.size = 10;
			txtcoinsCollected.size = 10;
			txtcompletedLevels.size = 10;
			txtDifficultyMod.size = 10;
			
			txtEnemiesKilled.visible = false;
			txtcoinsCollected.visible = false;
			txtcompletedLevels.visible = false;
			txtDifficultyMod.visible = false;
			
			add(txtEnemiesKilled);
			add(txtcoinsCollected);
			add(txtcompletedLevels);
			add(txtcompletedLevels);
			
			//Play again button
			this.setAll("scrollFactor", new FlxPoint(0, 0));
		}
		
		override public function update() : void {
			curDelay ++;
			switch(step) {
				case 0:
					add(scoreOverviewText(scoreOverviewX, scoreOverviewY, "Enemies Killed:  "));
					txtEnemiesKilled.visible = true;
					txtEnemiesKilled.x = scoreOverviewX + 100;
					txtEnemiesKilled.y = scoreOverviewY + 20 * step;
					
					step ++;
					break;
				//Enemies killed
				case 1:
					if (enemiesKilled < playerRef.enemiesKilled) {
						if (curDelay == totalDelay) {
							enemiesKilled++;
							curDelay = 0;
						}
					}
					else if (curDelay == totalDelay * 2) {
						curDelay = 0;
						add(scoreOverviewText(scoreOverviewX, scoreOverviewY + 20 * step, "Coins:  "));
						txtcoinsCollected.visible = true;
						txtcoinsCollected.x = scoreOverviewX + 100;
						txtcoinsCollected.y = scoreOverviewY + 20 * step;
						step++;
					}
					break;
					
				//Coins collected
				case 2:
					if (coinsCollected < playerRef.collectiblesCollected) {
						if (curDelay == totalDelay) {
							coinsCollected++;
							curDelay = 0;
						}
					}
					else if (curDelay == totalDelay * 2) {
						curDelay = 0;
						add(scoreOverviewText(scoreOverviewX, scoreOverviewY + 20 * step, "Levels:  "));
						txtcompletedLevels.visible = true;
						txtcompletedLevels.x = scoreOverviewX + 100;
						txtcompletedLevels.y = scoreOverviewY + 20 * step;
						step++;
					}
					break;
					
				//Completed levels
				case 3:
					if (completedLevels < playerRef.level) {
						if (curDelay == totalDelay) {
							completedLevels++;
							curDelay = 0;
						}
					}
					else if (curDelay == totalDelay * 2) {
						curDelay = 0;
						
						if (World.difficultyString == "easy") difficultyMult = .5;
						else if (World.difficultyString == "medium") difficultyMult = 1;
						else if (World.difficultyString == "hard") difficultyMult = 1.5;
						
						add(scoreOverviewText(scoreOverviewX, scoreOverviewY + 20 * step, "Difficulty:  "));
						txtDifficultyMod.visible = true;
						txtDifficultyMod.x = scoreOverviewX + 100;
						txtDifficultyMod.y = scoreOverviewY + 20 * step;
						
						step++;
					}
					break;
					
				//Difficulty Modifier
				case 4:
					break;
			
			}
			
			txtcompletedLevels.text = completedLevels.toString();
			txtEnemiesKilled.text = enemiesKilled.toString();
			txtcoinsCollected.text = coinsCollected.toString();
			txtDifficultyMod.text = difficultyMult.toString() + "x";
			
			super.update();
		}
		
		public function scoreOverviewText(x:int, y:int, text:String) : FlxText {
			var returned : FlxText = new FlxText(x, y, 100, text);
			returned.size = 10;
			returned.alignment = "right";
			returned.scrollFactor = new FlxPoint(0, 0);
			return returned;
		}
		
		public function scoreOverviewValue(x:int, y:int) : void {
			
		}
		
		public function snapRightSideTo(obj : FlxSprite, x : int) : void{
			obj.x = x - obj.frameWidth;
		}
		
		public function centerVertically(obj : FlxSprite) : void{
			obj.x = (CommonConstants.VISIBLEWIDTH / 2) - (obj.frameWidth / 2);
		}
		
		public function createButton(text : String) : FlxButton{
			var returned = new FlxButton(0,0,text);
			
			returned.width = 100;
			returned.height = 40;
			return returned;
		}
	}

}