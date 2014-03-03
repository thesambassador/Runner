package
{
	import org.flixel.*; 
	[SWF(width="800", height="600", backgroundColor="#000000")] //Set the size and color of the Flash file
	[Frame(factoryClass="Preloader")] //refers to Preloader.as to show the default Flixel loading screen
	
	public class Base extends FlxGame
	{
		public function Base()
		{
			super(CommonConstants.WINDOWWIDTH / CommonConstants.SCALEFACTOR, CommonConstants.WINDOWHEIGHT / CommonConstants.SCALEFACTOR, PlayState, CommonConstants.SCALEFACTOR); //
			this.forceDebugger = true;
			this.useSystemCursor = true;
			
		}
	}
}
