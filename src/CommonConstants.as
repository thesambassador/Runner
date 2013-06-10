package  
{
	/**
	 * ...
	 * @author ...
	 */
	public class CommonConstants 
	{
		public static var WINDOWWIDTH : Number = 800;
		public static var WINDOWHEIGHT : Number = 600;
		public static var SCALEFACTOR : Number = 2;
		
		public static var VISIBLEHEIGHT : Number = WINDOWHEIGHT / SCALEFACTOR;
		public static var VISIBLEWIDTH : Number = WINDOWWIDTH / SCALEFACTOR;
		
		public static var TILEWIDTH : Number = 16;
		public static var TILEHEIGHT : Number = 16;
		
		public static var LEVELHEIGHT : Number = 100;
		
		public static var JUMPHEIGHT : Number = 3; //maximum height in tiles that the player can jump vertically
		public static var JUMPLENGTH : Number = 10; // maximum length, assuming same-level sides, that the player can jump over horizontally
	}

}