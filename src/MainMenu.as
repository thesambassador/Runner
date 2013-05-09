package  
{
	import org.flixel.FlxButton;
	import org.flixel.FlxGroup;
	import org.flixel.FlxState;
	import org.flixel.FlxText;
	import org.flixel.FlxG;

	/**
	 * ...
	 * @author ...
	 */
	public class MainMenu extends FlxState
	{
		public var buttons : FlxGroup;
		
		public var startButton : FlxButton;
		public var logo : FlxText;
		
		public var easyDifficulty : FlxButton;
		public var mediumDifficulty : FlxButton;
		public var hardDifficulty : FlxButton;
		
		public var difficulty : String = "Medium";
		
		public var state : String = "intro";
		
		public var grey : uint;
		
		
		override public function create():void
		{
			FlxG.mouse.show();
			var middleScreen = CommonConstants.WINDOWWIDTH / 4;
			
			logo = new FlxText(middleScreen - 200, 30, 400, "ALIEN RUNNER");
			logo.size = 20;
			logo.alignment = "center";
			add(logo);
			
			startButton = new FlxButton(middleScreen, 100, "Start", startGame);
			startButton.x = middleScreen - (startButton.width / 2);
			var centeredButton = middleScreen - startButton.width / 2;
			
			//difficulty buttons
			easyDifficulty = new FlxButton(middleScreen, 150, "Easy", setEasy);
			easyDifficulty.x = centeredButton - easyDifficulty.width;
			
			mediumDifficulty = new FlxButton(middleScreen, 150, "Medium", setMedium);
			mediumDifficulty.x = centeredButton;
			mediumDifficulty.color = 0xFFFF00;
			
			hardDifficulty = new FlxButton(middleScreen, 150, "Hard", setHard);
			hardDifficulty.x = centeredButton + hardDifficulty.width;
			

			add(startButton);
			add(easyDifficulty);
			add(mediumDifficulty);
			add(hardDifficulty);
			
			grey = startButton.color;
		}
		
		override public function update():void {
			
			super.update();
		}
		
		public function startGame() {
			var startDiff : int = 1;
			var diffGain : int = 2;
			var monsterAcc : int = 15;
			var monsterVel : int = 150;
			
			switch(difficulty) {
				case "easy":
					startDiff = 1;
					diffGain = 2;
					monsterAcc = 15;
					monsterVel = 125;
					break;
				case "medium":
					startDiff = 2;
					diffGain = 3;
					monsterAcc = 17;
					monsterVel = 140;
					break;
				case "hard":
					startDiff = 5; 
					diffGain = 4;
					monsterAcc = 20;
					monsterVel = 150;
					break;
			}
			
			World.startingDifficulty = startDiff;
			World.difficultyGain = diffGain;
			World.monsterAcceleration = monsterAcc;
			World.startingMinMonsterVel = monsterVel;
			
			var playState = new PlayState();
			FlxG.switchState(playState);
		}
		
		public function setEasy() {
			difficulty = "easy";
			easyDifficulty.color = 0x00FF00;
			mediumDifficulty.color = grey;
			hardDifficulty.color = grey;
		}
		
		public function setMedium() {
			difficulty = "medium";
			easyDifficulty.color = grey;
			mediumDifficulty.color = 0xFFFF00;
			hardDifficulty.color = grey;
		}
		
		public function setHard() {
			difficulty = "hard";
			easyDifficulty.color = grey;
			mediumDifficulty.color = grey;
			hardDifficulty.color = 0xFF0000;
		}
	}

}