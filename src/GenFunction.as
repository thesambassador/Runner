package 
{
	
	/**
	 * Basic class for holding information on a particular level generation function
	 */
	public class GenFunction 
	{
		public var minDifficulty : int;
		public var maxDifficulty : int;
		public var genFunction : Function;
		public var category : String;
		public var bannedCategory : String;
		
		public function GenFunction(funct : Function, minD : int, maxD : int, cat : String, banned : String = "") {
			genFunction = funct;
			minDifficulty = minD;
			maxDifficulty = maxD;
			category = cat;
			bannedCategory = banned;
		}
	}
	
}