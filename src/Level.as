package  
{
	import org.flixel.system.FlxList;
	import org.flixel.*;

	/**
	 * Each "chunk" will be 1-2 screen widths of a level, stored as a FlxTilemap
	 * We will have 4-5 chunks "active" or "loaded" at a time.  As the player moves forward, it will unload the "first" chunk (farthest left) and load a new "last" chunk (farthest right).
	 * 
	 */
	public class Level 
	{
		[Embed(source = '../resources/img/auto_tiles.png')]private static var auto_tiles:Class;
		[Embed(source = '../resources/img/testTileset.png')]private static var grass:Class;
		
		private var firstChunk : Chunk ; //first chunk
		private var lastChunk : Chunk ; //last chunk
		private var chunkGen : ChunkGen;
		private var chunkNum : Number = 0;
		
		public var chunkGroup : FlxGroup;
		
		public var player : Player;
		
		//init
		public function Level() 
		{
			chunkGen = new ChunkGen();
			chunkGroup = new FlxGroup();
			FlxG.state.add(chunkGroup);
			
			//create player and add it to the map
			player = new Player(getStartX(), getStartY());
			FlxG.state.add(player);
			
			//set camera and world bounds
			FlxG.camera.setBounds(0, 0, 100, CommonConstants.LEVELHEIGHT * CommonConstants.TILEHEIGHT);
			FlxG.worldBounds = new FlxRect(0, 0, CommonConstants.TILEWIDTH * 8, CommonConstants.TILEHEIGHT * 8);
		}
		
		
		public function getStartX() : Number {
			return CommonConstants.TILEWIDTH * 10;
		}
		public function getStartY() : Number {
			return  (CommonConstants.LEVELHEIGHT - 5) * CommonConstants.TILEHEIGHT;
		}
		
		
		
		public function update() {
			
			FlxG.worldBounds.x = player.x;
			FlxG.worldBounds.y = player.y;
			
			//check collisions
			FlxG.collide(chunkGroup, player, player.collideTilemap);
			
			var camera : FlxCamera = FlxG.camera;
			var playerPoint : FlxPoint = player.getMidpoint();
			playerPoint.x += camera.width / 2 - 64;
			camera.focusOn(playerPoint);
			
			camera.setBounds(0, 0, player.x + 1000, CommonConstants.LEVELHEIGHT * CommonConstants.TILEHEIGHT);
			
			if (player.y > CommonConstants.LEVELHEIGHT * CommonConstants.TILEHEIGHT) {
				FlxG.resetState();
			}
			
			if (player.x > chunkGen.currentX - (CommonConstants.TILEWIDTH * 32)) {
				AppendNewChunk();
				//midChunkRight += chunkWidthPixels;
			}
			if (chunkNum > 20) {
				RemoveFirstChunk();
			}
		}
		
		private function AppendNewChunk() : void {
			//create new chunk
			var newChunk : Chunk = chunkGen.GenerateChunk();

			chunkGroup.add(newChunk.allLayers);

			//append it to the list
			if (firstChunk == null) {
				firstChunk = newChunk;
				lastChunk = newChunk;
			}
			else{
				lastChunk.nextChunk = newChunk;
				lastChunk = newChunk;
			}
			
			chunkNum ++;

		}
		
		private function RemoveFirstChunk() : void {
			var chunk1 : Chunk = firstChunk;
			chunkGroup.remove(chunk1.allLayers);
			firstChunk = firstChunk.nextChunk;
			chunkNum --;
		}
		

	}

}