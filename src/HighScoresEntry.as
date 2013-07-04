package  
{
	/**
	 * ...
	 * @author Sam Tregillus
	 */
	public class HighScoresEntry 
	{
		public var name : String;
		public var group : String;
		public var score : int;
		public var level : int;

		public function HighScoresEntry(n : String, g : String, s : int, l : int) 
		{
			name = n;
			group = g;
			score = s;
			level = l;
		}
		
	}

}