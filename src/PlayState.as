package
{
	import org.flixel.*;
	import org.flixel.system.FlxDebugger;

	public class PlayState extends FlxState
	{
		[Embed(source = '../resources/img/auto_tiles.png')]private static var auto_tiles:Class;
		
		public var runnerGen : StaticLevel;
		public var debugDiag : FlxDebugger;
		
		override public function create():void
		{
			//basic initialization
			FlxG.bgColor = 0xff000000;
			
			FlxG.framerate = 60;
			FlxG.flashFramerate = 60;

			
			runnerGen = new StaticLevel();
			
			
			FlxG.watch(runnerGen.player, "x", "Player X");
			//FlxG.visualDebug = true;
			
			
			

		}
		
		override public function update():void {
			super.update();
			
			runnerGen.update();
			
			

		}
		
	}
}