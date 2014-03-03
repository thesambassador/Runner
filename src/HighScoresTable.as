package  
{
	/**
	 * ...
	 * @author Sam Tregillus
	 */
	public class HighScoresTable 
	{
		public var entries : Vector.<HighScoresEntry>;
		
		public function HighScoresTable() {
			entries = new Vector.<HighScoresEntry>();
		}
		
		public function LoadFromXML(sxml : String) : void {
			entries.splice(0, entries.length);
			
			var xml : XML = new XML(sxml);
			
			for (var pname : String in xml.entry) {
				var name : String = xml.entry.name[pname];
				var group : String = xml.entry.group[pname];
				var score : int = int(xml.entry.score[pname]);
				var level : int = int(xml.entry.level[pname]);
				AddEntryByValues(name, group, score, level);
			}
		}
		
		public function AddEntryByValues(n : String, g : String, s : int, l : int) : void {
			var entry : HighScoresEntry = new HighScoresEntry(n, g, s, l);
			entries.push(entry);
		}
		
		public function AddEntry(entry : HighScoresEntry) : void {
			entries.push(entry);
		}
		
		public function GetGroupEntries(groupName : String) : HighScoresTable{
			var returned : HighScoresTable = new HighScoresTable();
			
			for each(var entry : HighScoresEntry in entries) {
				if (entry.group == groupName) {
					returned.AddEntry(entry);
				}
			}
			returned.SortByScore();
			return returned;
		}
		
		public function SortByScore() : void {
			entries.sort(ScoreCompare);
		}
		
		public function ScoreCompare(a : HighScoresEntry, b : HighScoresEntry) : int {
			if (a.score > b.score) return -1;
			else if (a.score < b.score) return 1;
			else return 0;
		}
		
	}

}