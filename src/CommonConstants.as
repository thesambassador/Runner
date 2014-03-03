package  
{
	import org.flixel.FlxSave;
	/**
	 * ...
	 * @author ...
	 */
	public class CommonConstants 
	{
		[Embed(source = '../resources/img/menuBackgroundLarge.png')]public static var MENUBG:Class;
		
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
		
		public static var SAVE : FlxSave;
		
		public static var SCORECOIN : int = 100;
		public static var SCOREENEMY : int = 500;
		public static var SCORELEVEL : int = 1000;
	}

}