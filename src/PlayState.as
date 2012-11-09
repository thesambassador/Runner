package
{
	import org.flixel.*;
	import org.flixel.system.FlxDebugger;

	public class PlayState extends FlxState
	{
		[Embed(source = '../resources/img/auto_tiles.png')]private static var auto_tiles:Class;

		public var player:Player;
		public var runnerGen : Level;
		
		override public function create():void
		{
			//basic initialization
			FlxG.bgColor = 0xff6b8cff;
			FlxG.framerate = 60;
			FlxG.flashFramerate = 60;
			
			
			runnerGen = new Level();
			

		}
		
		override public function update():void {
			super.update();
			
			runnerGen.update();

		}
		
	}
}