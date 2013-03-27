package 
{
	
	/**
	 * ...
	 * @author ...
	 */
	public class CommonFunctions
	{
		public static function getRandom(min:int, max:int) : int {
			return Math.round(Math.random() * (max - min)) + min;
		}
	}
	
}