package
{
	import org.flixel.*;
	import org.flixel.system.FlxDebugger;

	public class PlayState extends FlxState
	{
		
		public var world : World;
		public var debugDiag : FlxDebugger;
		
		override public function create():void
		{
			//basic initialization
			FlxG.bgColor = 0xff000000;
			FlxG.framerate = 60;
			FlxG.flashFramerate = 60;

		
			world = new World();
			this.add(world);

			FlxG.watch(world.player, "x", "Player X");
			FlxG.watch(world.player, "y", "Player Y");
			//FlxG.visualDebug = true;

		}
		
		override public function update():void {

			if (FlxG.keys.justPressed("P")) {
				FlxG.paused = (FlxG.paused ? false : true);
			}
			

			
			super.update();
			

		}
		
	}
}