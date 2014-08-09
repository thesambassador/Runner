package  
{
	import flash.geom.Point;
	import flash.events.Event;
	import org.flixel.FlxBasic;
	import org.flixel.FlxButton;
	import org.flixel.FlxGroup;
	import org.flixel.FlxSprite;
	import org.flixel.FlxText;
	import org.flixel.FlxPoint;
	import org.flixel.FlxG;
	import org.flixel.plugin.photonstorm.API.FlxKongregate;
	/**
	 * ...
	 * @author Sam Tregillus
	 */
	public class GameOverScreen extends FlxGroup
	{
		[Embed(source = '../resources/img/backgroundGameOver.png')]private static var gameOverBG:Class;
		
		public var playerRef : Player;
		
		//public var scoreOverview : ScoreOverview;
		public var highScoreView : HighScoresView;
		public var missions : MissionView;
		
		public var missionAnimationComplete : Boolean;
		
		public var gameOverGroup : FlxGroup;
		
		public var nameBox : FlxInputText;
		public var groupBox : FlxInputText;
		public var submitButton : FlxButton;
		public var skipButton : FlxButton;
		
		public var doneSubmitting : Boolean = false;
		public var submitting : Boolean = false;
		public var showingMissions : Boolean = true;
		
		public var score : int = 0;
		
		public function GameOverScreen(player : Player) 
		{
			FlxG.mouse.show();
			playerRef = player;
			
			gameOverGroup = new FlxGroup();
			add(gameOverGroup);
			
			//add background
			var background : FlxSprite = new FlxSprite();
			background.loadGraphic(gameOverBG);
			gameOverGroup.add(background);
			
			//add end of game score, player's best score, and name input
			
			//add "skip" and "submit" buttons
			
			//add the mission display
			missions = new MissionView();
			gameOverGroup.add(missions);
			missions.StartMissionAnimation(DoneAnimatingMissions);
			
			//show the score, save it if it's the best one
			CommonFunctions.saveScore(player.score);
			var bestScore : int = CommonConstants.SAVE.data.BestScore;
			score = player.score;
			
			var scoreText : FlxText = new FlxText(110, 67, 200, score.toString());
			var bestScoreText : FlxText = new FlxText(110, 86, 200, bestScore.toString());
			scoreText.size = 10;
			bestScoreText.size = 10;
			
			gameOverGroup.add(scoreText);
			gameOverGroup.add(bestScoreText);
			
			//AddInputs();
			
			//scoreOverview = new ScoreOverview();
			//add(scoreOverview);
			//scoreOverview.StartScoreOverview(player.collectiblesCollected, player.enemiesKilled, player.level);
		

			this.setAll("scrollFactor", new FlxPoint(0, 0));
			gameOverGroup.setAll("scrollFactor", new FlxPoint(0, 0));
		}
		
		public function AddInputs() : void {
			/*
			nameBox = new FlxInputText(215, 77, CommonConstants.SAVE.data.name, 100, 0xFFFFFFFF, 0xFF000000);
			nameBox.maxLength = 15;
			nameBox.filterMode = FlxInputText.ONLY_ALPHANUMERIC;
			gameOverGroup.add(nameBox);
			
			submitButton = new FlxButton(290, 255, "Submit", SubmitScore);
			gameOverGroup.add(submitButton);
			*/
			

			
			//var submitShortcut : FlxText = new FlxText(290, 243, 80, "(Enter)");
			//submitShortcut.alignment = "center";
			//gameOverGroup.add(submitShortcut);
			
			//skipButton = new FlxButton(30, 255, "Next", SkipScore);
			//gameOverGroup.add(skipButton);
		}
		
		override public function update() : void {
			super.update();
			
			//if (FlxG.keys.justPressed("ENTER") && !doneSubmitting) {
			//	SubmitScore();
			//}
			
			if (FlxG.keys.justPressed("SPACE") && missionAnimationComplete) {
				resetState();
			}
			
			if (missionAnimationComplete && showingMissions) {
				showingMissions = false;
				
				//gameOverGroup.visible = false;
				//gameOverGroup.active = false;
				
				//var bg : FlxSprite = new FlxSprite(0, 0, CommonConstants.MENUBG);
				//bg.scrollFactor.x = 0;
				//bg.scrollFactor.y = 0;
				//add(bg);
				
				var skipShortcut : FlxText = new FlxText(290, 230, 80, "(Space)");
				skipShortcut.scrollFactor.x = 0;
				skipShortcut.scrollFactor.y = 0;
				skipShortcut.alignment = "center";
				add(skipShortcut);
				
				var btnNext : FlxButton = new FlxButton(290, 243, "Play Again", resetState);
				btnNext.scrollFactor.x = 0;
				btnNext.scrollFactor.y = 0;
				add(btnNext);
				
				//highScoreView = new HighScoresView();
				//add(highScoreView);
				//highScoreView.RefreshScores();
				//highScoreView.ShowEntries();
			}
				
			/*
			if (scoreOverview.done && highScoreView == null) {
				remove(scoreOverview);
				scoreOverview.destroy();
				highScoreView = new HighScoresView();
				add(highScoreView);
				highScoreView.RefreshScores();
				highScoreView.ShowEntries();
			}
			*/
		}
		
		//commenting out this crap for kongregate
		/*
		public function SubmitScore() : void {
			if(!submitting){
				if(nameBox.text.length > 0){ //&& groupBox.text.length > 0){
					HighScoresView.SubmitScore(nameBox.text, "", score, playerRef.level, MissionManager.missionManagerInstance.currentRank, SkipScore);
					submitting = true;
					submitButton.label.text = "Submitting";
				}
			}
		}
		
		public function SkipScore(evt : Event = null) : void {
			CommonFunctions.saveUserSettings(nameBox.text, "");// groupBox.text);
			submitButton.label.text = "done";
			doneSubmitting = true;
		}
		*/
		
		public function DoneAnimatingMissions() {
			missionAnimationComplete = true;
		}
		
		public function resetState() : void {
			try {
				FlxKongregate.api.stats.submit("HighScore", score);
			}
			catch (error:Error) {
				
			}
			PlayState.playImmediately = true;
			FlxG.resetGame();
		}
	}

}