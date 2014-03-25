package  
{
	import org.flixel.FlxBasic;
	import org.flixel.FlxButton;
	import org.flixel.FlxGroup;
	import org.flixel.FlxParticle;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	import org.flixel.FlxText;
	import org.flixel.FlxG;
	
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequestMethod;
	import flash.events.Event;
	/**
	 * ...
	 * @author Sam Tregillus
	 */
	public class HighScoresView extends FlxGroup
	{
		public var highscores : HighScoresTable;
		
		private var currentDisplay : FlxGroup;
		
		private var btnRefresh : FlxButton;
		private var btnFilter : FlxButton;
		private var btnNext : FlxButton;
		
		private var inputFilter : FlxInputText;
		
		private var currentRow : int = 1;
		private var rowStartY : int = 50;
		//private var rowY : int = 70;
		private var rowHeight : int = 15;
		
		private var windowWidth : int = 400;
		private var margin : int = 20;
		private var highScoreWidth : int = windowWidth - 2 * margin;
		
		private var xNum : int = margin;
		private var xName : int = margin + highScoreWidth *.1;
		private var xGroup : int = margin + highScoreWidth * .4;
		private var xScore : int = margin + highScoreWidth * .7;
		private var xLevel : int = margin + highScoreWidth * .9;
		
		public function HighScoresView() {
			super();
			
			currentDisplay = new FlxGroup();
			highscores = new HighScoresTable();
			
			var nameHeader : FlxText = new FlxText(xName, rowStartY, 100, "Name");
			//var groupHeader : FlxText = new FlxText(xGroup, rowStartY, 100, "Group");
			var scoreHeader : FlxText = new FlxText(xScore, rowStartY, 100, "Score");
			var levelHeader : FlxText = new FlxText(xLevel, rowStartY, 100, "Level");
			var topDivider : FlxSprite = new FlxSprite(20, rowStartY + 15);
			topDivider.makeGraphic(400 - 40, 2);
			
			btnFilter = new FlxButton(20, 20, "Filter", FilterGroup);
			
			if(FlxG.state is PlayState){
				btnNext = new FlxButton(CommonConstants.VISIBLEWIDTH - 120, 20, "Play Again", resetState);
			}
			else {
				btnNext = new FlxButton(CommonConstants.VISIBLEWIDTH - 120, 20, "Back", resetState);
			}
			
			
			inputFilter = new FlxInputText(100, 22.5, CommonConstants.SAVE.data.group, 100, 0xFFFFFFFF, 0xFF000000);
			inputFilter.borderColor = 0xFFFFFFFF;
			inputFilter.borderThickness = 1;
			inputFilter.enterCallBack = FilterGroup;
			
			//add(btnFilter);
			//add(inputFilter);
			add(btnNext);
			
			btnRefresh = new FlxButton(0, 280, "Refresh", RefreshScores);
			btnRefresh.x = 200 - btnRefresh.frameWidth / 2;
			
			//add(btnRefresh);
			add(currentDisplay);
			add(topDivider);
			
			add(nameHeader);
			//add(groupHeader);
			add(scoreHeader);
			add(levelHeader);

		}
		
		public function AddEntryToTable(entry : HighScoresEntry) : void {
			var rowY : int = rowStartY + rowHeight * currentRow + 5;
			
			if (currentRow > 13) return;
			
			var rowNumber : FlxText = new FlxText(xNum, rowY, 30, currentRow.toString());
			var rowName : FlxText = new FlxText(xName, rowY, 100, entry.name);
			//var rowGroup: FlxText = new FlxText(xGroup, rowY, 100, entry.group);
			var rowScore : FlxText = new FlxText(xScore, rowY, 100, entry.score.toString());
			var rowLevel : FlxText = new FlxText(xLevel, rowY, 100, entry.level.toString());
			
			
			rowNumber.scrollFactor = new FlxPoint();
			rowName.scrollFactor = new FlxPoint();
			//rowGroup.scrollFactor = new FlxPoint();
			rowScore.scrollFactor = new FlxPoint();
			rowLevel.scrollFactor = new FlxPoint();
			
			
			currentDisplay.add(rowNumber);
			currentDisplay.add(rowName);
			//currentDisplay.add(rowGroup);
			currentDisplay.add(rowScore);
			currentDisplay.add(rowLevel);
			
			rowY += rowHeight;
			currentRow += 1;
		}
		
		public function ShowEntries() : void {
			if(currentDisplay != null){
				currentDisplay.clear();
				currentRow = 1;
				
				highscores.SortByScore();
				
				
				for each(var entry : HighScoresEntry in highscores.entries) {
					if(currentRow * rowHeight < 380)
						AddEntryToTable(entry);
					else 
						break;
				}
			}
		}
		
		public function RefreshScores(filter : Boolean = false ) : void {
			var request : URLRequest = new URLRequest("http://www.thesambassador.com/files/highscore.php");
			var loader : URLLoader = new URLLoader();
			btnRefresh.label.text = "...";
			btnRefresh.label.alignment = "center";
			//var requestVars : URLVariables = new URLVariables();
				
			//requestVars.name = "Sam";
			//requestVars.score = 56;
			//requestVars.group = "TestGroup";
			//requestVars.level = 6;
				
			//request.method = URLRequestMethod.POST;
			//request.data = requestVars;

			loader.dataFormat = URLLoaderDataFormat.TEXT;
			if (filter)
				loader.addEventListener(Event.COMPLETE, FinishFilter);
			else
				loader.addEventListener(Event.COMPLETE, FinishRefresh);
			loader.load(request);
		}
		
		public static function SubmitScore(name : String, group : String, score : int, level : int, rank : int, finishFunction : Function) : void {
			var request : URLRequest = new URLRequest("http://www.thesambassador.com/files/highscore.php");
			var loader : URLLoader = new URLLoader();
			var requestVars : URLVariables = new URLVariables();
				
			requestVars.name = name;
			requestVars.score = score;
			requestVars.group = group;
			requestVars.level = level;
			requestVars.rank = rank;
				
			request.method = URLRequestMethod.POST;
			request.data = requestVars;

			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE, finishFunction);
			loader.load(request);
		}
		
		public function FinishRefresh(evt : Event) : void {
			if (evt.target is URLLoader) {
				var loader : URLLoader = evt.target as URLLoader;
				highscores.LoadFromXML(loader.data);
				ShowEntries();
				btnRefresh.label.text = "Refresh";
			}
		}
		
		public function FilterGroup(text : String = "") : void {
			RefreshScores(true);
		}
		
		public function FinishFilter(evt : Event) : void {
			if (evt.target is URLLoader) {
				var loader : URLLoader = evt.target as URLLoader;
				highscores.LoadFromXML(loader.data);
				ShowEntries();
				btnRefresh.label.text = "Refresh";
			}
			if (inputFilter.text != "") {
				highscores = highscores.GetGroupEntries(inputFilter.text);
			}
			ShowEntries();
		}
		
		public function resetState() : void {
			PlayState.playImmediately = true;
			FlxG.resetGame();
		}
		
		override public function update() : void {
			super.update();
			
			if (FlxG.keys.justPressed("ENTER")) {
				PlayState.playImmediately = true;
				FlxG.resetGame();
			}
		}
		
		override public function add(object : FlxBasic) : FlxBasic{
			if (object is FlxGroup) {
				(object as FlxGroup).setAll("scrollFactor", new FlxPoint());
				super.add(object);
			}
			else if(object is FlxSprite){
				(object as FlxSprite).scrollFactor = new FlxPoint();
				super.add(object);
			}
			else {
				super.add(object);
			}
			return object;
		}
		
		
	}

}