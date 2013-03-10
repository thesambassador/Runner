package
{
	import org.flixel.*; //Allows you to refer to flixel objects in your code
	[SWF(width="800", height="600", backgroundColor="#000000")] //Set the size and color of the Flash file

	public class Base extends FlxGame
	{
		public function Base()
		{
			super(CommonConstants.WINDOWWIDTH / 2, CommonConstants.WINDOWHEIGHT / 2, PlayState, 2); //Create a new FlxGame object and load "PlayState"
			this.forceDebugger = true;
			
		}
	}
}
