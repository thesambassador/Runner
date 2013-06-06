package 
{
	
	/**
	 * Basic class for holding information on a particular level generation function
	 */
	public class GenFunction 
	{
		public var name : String;
		public var minDifficulty : int;
		public var maxDifficulty : int;
		public var genFunction : Function;
		public var category : String;
		
		public function GenFunction(n : String, funct : Function, minD : int, maxD : int, cat : String) {
			name = n;
			genFunction = funct;
			minDifficulty = minD;
			maxDifficulty = maxD;
			category = cat;
		}
	}
	
}