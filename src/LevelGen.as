package 
{
	import org.flixel.*;
	/**
	 * This is the base LevelGen class
	 * It has basic functions for creating things that all levels need
	 * Actual levels will inherit from this.
	 */
	public class LevelGen
	{
		public static var endBuffer : int = 10; //stop generating level pieces once we get to total width of the level minus endBuffer.
		
		public var currentX : int; //tile coords
		public var currentY : int; //tile coords
		
		public var tileset : Class //tileset to use to generate
		
		public var baseFunctions : Array;  //array of base functions that are valid to use.
		
		public var currentChunk : Chunk; //current chunk we're operating on, generated when we create the LevelGen object
		
		public function LevelGen(initialElevation : int, width : int, tileset : Class) {
			currentX = 0;
			currentY = initialElevation;
			
			baseFunctions = new Array();
			baseFunctions.push(GenFlat);
			baseFunctions.push(GenElevationChange);
			baseFunctions.push(GenGap);
			
			currentChunk = new Chunk(tileset, width);
			
		}
		
		public function GenerateLevel() : Chunk{
			while (currentX < currentChunk.mainTiles.widthInTiles - endBuffer) {
				var genFunction : Function = FlxU.getRandom(baseFunctions) as Function;
				
				genFunction();
			}
			
			//fill in the rest of the level with flatness
			while (currentX < currentChunk.widthInTiles) {
				var setTile = 1;
				
				if (currentX == currentChunk.widthInTiles - 1) setTile = 9;
				
				currentChunk.mainTiles.setTile(currentX, currentY, setTile);
				FillUnder(currentX, currentY, currentChunk.mainTiles, 4);
				
				currentX ++;
			}
			
			return currentChunk;
		}

		protected function GenFlat(w:int = -1) {
			var width : int ;
			if(w == -1)
				width = getRandom(8, 15);
			else
				width = w;
			
			for (var x : int = currentX; x < width + currentX; x++) {
				var setTile : int = 1;
				
				if (x == currentX + width - 1) {
					setTile = 10;
				}
				
				currentChunk.mainTiles.setTile(x, currentY, setTile);
				
				FillUnder(x, currentY, currentChunk.mainTiles, 4);
			}
			currentX += width;

		}
		
		protected function GenElevationChange() {
			if (currentY > CommonConstants.LEVELHEIGHT - 2) {
				currentY += getRandom( -2, -1);
			}
			else if (currentY <= 2) {
				currentY += getRandom(2, 1);
			}
			else {
				currentY += getRandom( -2, 2);
			}
			GenFlat(2);
		}
		
		protected function GenGap(w:int = -1) {		
			
			var width : int ;
			if(w == -1)
				width = getRandom(2, 8);
			else
				width = w;
			
			currentChunk.mainTiles.setTile(currentX, currentY, 10);
			FillUnder(currentX, currentY, currentChunk.mainTiles, 4);
			
			currentChunk.mainTiles.setTile(currentX + width-1, currentY, 10);
			FillUnder(currentX + width - 1, currentY, currentChunk.mainTiles, 4);
			
			currentX += width;
		}
		
		//this is the same as flat, but a bit wider and adds multiple "levels" that the player can jump onto for some variation
		protected function GenMultiLevel(w:int = -1) {
			
			var width : int ;
			if(w == -1)
				width = getRandom(10, 15);
			else
				width = w;
			
			var returned : Chunk = GenFlat(width);
			
			//number of additional levels (not including the ground)
			var numLevels : int = getRandom(1, 3);
			
			//higher levels must be generated first, each level will be a random width and height
			while (numLevels > 0) {
				var genX : int = getRandom(0, currentChunk.widthInTiles - 3);
				while (genX < currentChunk.width - 6) {
					var h : int = numLevels * CommonConstants.JUMPHEIGHT - getRandom(0, 1);
					var w : int = getRandom(2, currentChunk.width - genX - 1);
					currentChunk.AddOneWayPlatform(genX, currentY - 1, w, h);
					
					var spacing : int = getRandom(1, 4);
					
					genX = genX + w + spacing;
				}
				numLevels --;
			}
			

		}
		
		//fill all tiles under the specific tile.
		protected function FillUnder(sx:int, sy:int, tiles:FlxTilemap, fillTile:int = 1) : void {
			for (var y : int = sy + 1; y < CommonConstants.LEVELHEIGHT; y++) {
				tiles.setTile(sx, y, fillTile);
			}
		}
		
		protected function GetDifficulty() : int{
			return 1;
		}
		
		protected function getRandom(min:int, max:int) : int {
			return Math.round(Math.random() * (max - min)) + min;
		}
	}
	
}