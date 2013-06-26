package  
{
	import org.flixel.FlxU;
	/**
	 * ...
	 * @author Sam Tregillus
	 */
	public class GenFunctionHelper 
	{
		public var genFunctions : Array;
		
		public function GenFunctionHelper() 
		{
			genFunctions = new Array();
		}
		
		public function addFunction(name : String, funct : Function, minD : int, maxD : int, cat : String, weight:int = 1) : void {
			for (var i : int = 0; i < weight; i++)
				genFunctions.push(new GenFunction(name, funct, minD, maxD, cat));
		}
		
		//get an array of all valid functions for this difficulty
		//excludeCategory specifies a category to not include in the list
		//excludeName specfies a name to not include in the list
		public function getValidFunctionArray(diff : int, excludeCategory : String = "", excludeName : String = "") : Array {
			var validFunctions : Array = new Array();
			
			for each(var genFunct : GenFunction in genFunctions) {
				if (diff >= genFunct.minDifficulty && diff <= genFunct.maxDifficulty) {
					if(genFunct.name != excludeName && genFunct.category != excludeCategory)
						validFunctions.push(genFunct);
				}
			}
			
			return validFunctions;
		}
		
		public function getRandomValidFunction(diff : int, excludeCategory : String = "", excludeName : String = "") : GenFunction {
			var validFunctions : Array = getValidFunctionArray(diff, excludeCategory, excludeName);
			return FlxU.getRandom(validFunctions) as GenFunction;
		}
		
	}

}