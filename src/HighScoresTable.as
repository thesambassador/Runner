package  
{
	/**
	 * ...
	 * @author Sam Tregillus
	 */
	public class HighScoresTable 
	{
		public var entries : Vector.<HighScoresEntry>;
		
		public function HighScoresTable() 
		{
			entries = new Vector.<HighScoresEntry>();
		}
		
		public function LoadFromXML(sxml : String) : void {
			
		}
		
		public function AddEntryByValues(n : String, g : String, s : int, l : int) {
			var entry : HighScoresEntry = new HighScoresEntry(n, g, s, l);
			entries.push(entry);
		}
		
		public function AddEntry(entry : HighScoresEntry) {
			entries.push(entry);
		}
		
		public function GetGroupEntries(groupName : String) : HighScoresTable{
			var returned : HighScoresTable = new HighScoresTable();
			
			for (var entry : HighScoresEntry in entries) {
				if (entry.group == groupName) {
					returned.AddEntry(entry);
				}
			}
			returned.SortByScore();
			return returned;
		}
		
		public function SortByScore() {
			entries.sort(ScoreCompare);
		}
		
		public function ScoreCompare(a : HighScoresEntry, b : HighScoresEntry) : int {
			if (a.score > b.score) return -1;
			else if (a.score < b.score) return 1;
			else return 0;
		}
		
	}

}