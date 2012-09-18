package
{
	import org.flixel.*;
	import org.flixel.system.FlxDebugger;

	public class PlayState extends FlxState
	{
		[Embed(source = '../resources/img/auto_tiles.png')]private static var auto_tiles:Class;

		public var player:Player;
		public var runnerGen : RunnerGen;
		
		override public function create():void
		{
			//basic initialization
			FlxG.bgColor = 0xff6b8cff;
			FlxG.framerate = 60;
			FlxG.flashFramerate = 60;
			
			//create initial frames and add them to the map
			runnerGen = new RunnerGen();
			add(runnerGen.chunkGroup);
			
			
			//create player and add it to the map
			player = new Player(runnerGen.getStartX(), runnerGen.getStartY());
			add(player);
			
			//set camera to follow player
			FlxG.camera.setBounds(0, 0, 100, CommonConstants.LEVELHEIGHT * CommonConstants.TILEHEIGHT);
			//FlxG.camera.follow(player);
			
			FlxG.worldBounds = new FlxRect(0, 0, CommonConstants.TILEWIDTH * 8, CommonConstants.TILEHEIGHT * 8);
		}
		
		override public function update():void {
			super.update();
			
			runnerGen.update(player.x, player.y);
			
			FlxG.worldBounds.x = player.x;
			FlxG.worldBounds.y = player.y;
			
			//check collisions
			FlxG.collide(runnerGen.chunkGroup, player, player.collideTilemap);
			
			
			var camera : FlxCamera = FlxG.camera;
			var playerPoint : FlxPoint = player.getMidpoint();
			playerPoint.x += camera.width / 2 - 64;
			camera.focusOn(playerPoint);
			
			camera.setBounds(0, 0, player.x + 1000, CommonConstants.LEVELHEIGHT * CommonConstants.TILEHEIGHT);
			
			if (player.y > CommonConstants.LEVELHEIGHT * CommonConstants.TILEHEIGHT) {
				FlxG.resetState();
			}
		}
		
	}
}