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
		
		public var playerRef : Player;
		
		public var scoreOverview : ScoreOverview;
		public var highScoreView : HighScoresView;
		
		public function GameOverScreen(player : Player) 
		{
			FlxG.mouse.show();
			playerRef = player;
				
			var background : FlxSprite = new FlxSprite();
			background.loadGraphic(CommonConstants.MENUBG);
			background.alpha = 1;
			add(background);
			
			
			scoreOverview = new ScoreOverview();
			add(scoreOverview);
			scoreOverview.StartScoreOverview(player.collectiblesCollected, player.enemiesKilled, player.level);
		
			//Play again button
			this.setAll("scrollFactor", new FlxPoint(0, 0));
		}
		
		override public function update() : void {
			super.update();
			
			if (scoreOverview.done && highScoreView == null) {
				remove(scoreOverview);
				scoreOverview.destroy();
				highScoreView = new HighScoresView();
				add(highScoreView);
				highScoreView.RefreshScores();
				highScoreView.ShowEntries();
			}
			
		}
		
	}

}