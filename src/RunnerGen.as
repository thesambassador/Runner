package  
{
	import org.flixel.FlxGroup;
	import org.flixel.FlxTilemap;
	import org.flixel.FlxObject;
	import org.flixel.system.FlxList;
	import org.flixel.FlxG;

	/**
	 * Each "chunk" will be 1-2 screen widths of a level, stored as a FlxTilemap
	 * We will have 4-5 chunks "active" or "loaded" at a time.  As the player moves forward, it will unload the "first" chunk (farthest left) and load a new "last" chunk (farthest right).
	 * 
	 */
	public class RunnerGen 
	{
		[Embed(source = 'auto_tiles.png')]private static var auto_tiles:Class;
		[Embed(source = 'testTileset.png')]private static var grass:Class;
		
		private var firstChunk : FlxList ; //first chunk
		private var lastChunk : FlxList ; //last chunk
		
		public var chunkGroup : FlxGroup;
		
		private var sectionGen : SectionGen;
		
		//init
		public function RunnerGen() 
		{
			sectionGen = new SectionGen(CommonConstants.LEVELHEIGHT - 1);
			chunkGroup = new FlxGroup();
			
		}
		
		
		public function getStartX() : Number {
			return CommonConstants.TILEWIDTH * 10;
		}
		public function getStartY() : Number {
			return  (CommonConstants.LEVELHEIGHT - 5) * CommonConstants.TILEHEIGHT;
		}
		
		
		
		public function update(playerX:int, playerY:int) {
			
			if (playerX > sectionGen.currentX - (CommonConstants.TILEWIDTH * 16)) {
				AppendNewChunk();
				//midChunkRight += chunkWidthPixels;
			}
			
		}
		
		private function AppendNewChunk() : void {
			//create new chunk
			var newSection : FlxTilemap = sectionGen.GenerateSection();
			var newList : FlxList = new FlxList();
			newList.object = newSection;
			chunkGroup.add(newSection);

			//append it to the list
			if (firstChunk == null) {
				firstChunk = newList;
				lastChunk = newList;
			}
			else{
				lastChunk.next = newList;
				lastChunk = newList;
			}
			
			//remove the first item if we need to
			
			
		}
		
		private function GenerateLevel() : void {
			
			
		}
		
	
	
		
	}

}