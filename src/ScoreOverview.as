package 
{
	import flash.events.Event;
	import org.flixel.FlxButton;
	import org.flixel.FlxGroup;
	import org.flixel.FlxObject;
	import org.flixel.FlxPoint;
	import org.flixel.FlxText;
	import org.flixel.FlxSprite;
	
	/**
	 * ...
	 * @author Sam Tregillus
	 */
	public class ScoreOverview extends FlxGroup 
	{	
		
		public var labels : Vector.<String>;
		public var countdowns : Vector.<int>;
		
		private var go : Boolean = false;
		public var done : Boolean = false;
		
		private var margin : int = 20;
		private var overviewStartY : int = 60;
		private var overviewSpacing : int = 15;
		
		public var delay : int = 1;
		public var curDelay : int = 0;
		public var step : int = 0;
		
		public var levelsDone : int = 0;
		public var totalScore : int = 0;
		
		public var curCountText : CountText;
		
		public var nameBox : FlxInputText;
		public var groupBox : FlxInputText;
		public var submitButton : FlxButton;
		public var skipButton : FlxButton;
		
		public var submitting : Boolean;
		
		public function ScoreOverview() {
			super();
			add(CenteredText("Game Over", 30, 20));
			
		}
		
		public function StartScoreOverview(coins : int, enemies : int, levels : int) : void {
			
			labels = new Vector.<String>();
			countdowns = new Vector.<int>();
			
			labels.push("Coins Collected");
			labels.push("Enemies Killed");
			labels.push("Levels Completed");
			labels.push("Total");
			
			countdowns.push(coins);
			countdowns.push(enemies);
			countdowns.push(levels);
			
			totalScore = coins * CommonConstants.SCORECOIN + enemies * CommonConstants.SCOREENEMY + levels * CommonConstants.SCORELEVEL;
			levelsDone = levels;
			
			countdowns.push(totalScore);
			
			go = true;
			
			add(CenteredText(labels[0], overviewStartY));
			curCountText = new CountText(0, overviewStartY + overviewSpacing, 50);
			CenterVertically(curCountText);
			add(curCountText);
			curCountText.start(0, countdowns[0], delay);
		}
		
		override public function update() : void {
			if (go) {
				if (curCountText.done) {
					step++;
					if(step < labels.length){
						add(CenteredText(labels[step], overviewStartY + 2 * overviewSpacing * step));
						curCountText = new CountText(0, overviewStartY + 2 * overviewSpacing * step + overviewSpacing, 50);
						CenterVertically(curCountText);
						add(curCountText);
						curCountText.start(0, countdowns[step], delay);
						
						if (step == labels.length - 1) {
							curCountText.increment = 100;
							curCountText.delay = 1;
						}
					}
					else if (step == labels.length) {
						go = false;
						AddScoreSubmit();
						step ++;
					}
				}
			}
			super.update();
		}
		
		public function AddScoreSubmit() : void {
			var elementY : int = CommonConstants.VISIBLEHEIGHT - 2*margin;
			var labelY : int = elementY - 15;
			
			nameBox = new FlxInputText(10, elementY, CommonConstants.SAVE.data.name, 100, 0xFFFFFFFF, 0xFF000000);
			nameBox.maxLength = 15;
			nameBox.filterMode = FlxInputText.ONLY_ALPHANUMERIC;

			var nameLabel : FlxText = new FlxText(10, labelY, 100, "Name");
			nameLabel.alignment = "center";
			nameBox.scrollFactor = new FlxPoint();
			nameLabel.scrollFactor = new FlxPoint();
			add(nameBox);
			add(nameLabel);
			
			groupBox = new FlxInputText(115, elementY, CommonConstants.SAVE.data.group, 100, 0xFFFFFFFF, 0xFF000000);
			var groupLabel : FlxText = new FlxText(115, labelY, 100, "Group");
			groupLabel.alignment = "center";
			groupBox.maxLength = 15;
			nameBox.filterMode = FlxInputText.ONLY_ALPHANUMERIC;

			groupBox.scrollFactor = new FlxPoint();
			groupLabel.scrollFactor = new FlxPoint();
			add(groupBox);
			add(groupLabel);
			
			submitButton = new FlxButton(220, elementY, "Submit", SubmitScore);
			submitButton.scrollFactor = new FlxPoint();
			submitButton.y -= 2.5;
			add(submitButton);
			
			skipButton = new FlxButton(310, elementY, "Skip", SkipScore);
			skipButton.scrollFactor = new FlxPoint();
			skipButton.y -= 2.5;
			add(skipButton);
			
		}
		
		public function SubmitScore() : void {
			if(!submitting){
				if(nameBox.text.length > 0 && groupBox.text.length > 0){
					HighScoresView.SubmitScore(nameBox.text, groupBox.text, totalScore, levelsDone, SkipScore);
					submitting = true;
					submitButton.label.text = "Submitting";
				}
			}
		}
		
		public function SkipScore(evt : Event = null) : void {
			CommonFunctions.saveUserSettings(nameBox.text, groupBox.text);
			done = true;
		}
		
		public function CenteredText(text : String, y : int, textSize : int = 10) : FlxText {
			var returned : FlxText = new FlxText(0, y, 400, text);
			returned.size = textSize;
			returned.alignment = "center";
			returned.scrollFactor = new FlxPoint();
			returned.x = (CommonConstants.VISIBLEWIDTH / 2) - (returned.frameWidth / 2);
			return returned;
		}
		
		public function CenterVertically(obj : FlxSprite) : void{
			obj.x = (CommonConstants.VISIBLEWIDTH / 2) - (obj.frameWidth / 2);
			
		}
		
		
	}
	
}