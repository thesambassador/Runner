package  
{
	import org.flixel.*;
	/**
	 * ...
	 * @author ...
	 */
	import org.flixel.FlxTilemap;
	 
	public class ChunkGen 
	{
		public var currentX : int;
		public var currentElevation : int;
		
		public var difficultyFactor : int = 500;
		public var tileset : Class;
		
		public function ChunkGen(startingX:int = 0, startingHeight:int = -1) 
		{
			currentX = startingX;
			if (startingHeight == -1)
				currentElevation = CommonConstants.LEVELHEIGHT - 1;
			else
				currentElevation = startingHeight;
		
		}
		
		public function GenerateChunk() : Chunk{
			var newChunk : Chunk; 
			
			var genFunction : Function = FlxU.getRandom(GetValidFunctions()) as Function;
			newChunk = genFunction();
			
			newChunk.SetX(currentX);
			newChunk.Decorate();
			
			currentX += newChunk.mainTiles.width;
			
			return newChunk;
		}
			
		//get a list of currently valid level generation functions
		protected function GetValidFunctions() : Array {
			var functions : Array = new Array();
			
			functions.push(GenFlat);
			functions.push(GenElevationChange);
			functions.push(GenGap);
			
			return functions;
		}
		
		protected function GenFlat(w:int = -1) : Chunk {
			var width : int ;
			if(w == -1)
				width = getRandom(8, 15);
			else
				width = w;
			
			var returned : Chunk = new Chunk(tileset, width);
			
			for (var x : int = 0; x < width; x++) {
				var setTile : int = 1;
				
				if (x == width - 1) {
					setTile = 17;
				}
				
				returned.mainTiles.setTile(x, currentElevation, setTile);
				
				FillUnder(x, currentElevation, returned.mainTiles, 4);
			}
			
			
			return returned;
		}
		
		protected function GenElevationChange() : Chunk {
			if (currentElevation > CommonConstants.LEVELHEIGHT - 2) {
				currentElevation += getRandom( -2, -1);
			}
			else if (currentElevation <= 2) {
				currentElevation += getRandom(2, 1);
			}
			else {
				currentElevation += getRandom( -2, 2);
			}
			return GenFlat(2);
		}
		
		protected function GenGap(w:int = -1) : Chunk {		
			
			var width : int ;
			if(w == -1)
				width = getRandom(2, 6);
			else
				width = w;
			
			var returned : Chunk = new Chunk(tileset, width);
			
			returned.mainTiles.setTile(0, currentElevation, 1);
			FillUnder(0, currentElevation, returned.mainTiles, 4);
			
			returned.mainTiles.setTile(width-1, currentElevation, 1);
			FillUnder(width-1, currentElevation, returned.mainTiles, 4);

			return returned;
		}
		
		//this is the same as flat, but a bit wider and adds multiple "levels" that the player can jump onto for some variation
		protected function GenMultiLevel(w:int = -1) : Chunk {
			
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
				var genX : int = getRandom(0, returned.width - 3);
				while (genX < returned.width - 6) {
					var h : int = numLevels * CommonConstants.JUMPHEIGHT - getRandom(0, 1);
					var w : int = getRandom(2, returned.width - genX - 1);
					returned.AddOneWayPlatform(genX, currentElevation - 1, w, h);
					
					var spacing : int = getRandom(1, 4);
					
					genX = genX + w + spacing;
				}
				numLevels --;
			}
			
			
			return returned;
		}
		
		//fill all tiles under the specific tile.
		protected function FillUnder(sx:int, sy:int, tiles:FlxTilemap, fillTile:int = 1) : void {
			for (var y : int = sy + 1; y < CommonConstants.LEVELHEIGHT; y++) {
				tiles.setTile(sx, y, fillTile);
			}
		}
		
		protected function GetDifficulty() : int{
			return currentX / difficultyFactor;
		}
		
		protected function getRandom(min:int, max:int) : int {
			return Math.round(Math.random() * (max - min)) + min;
		}
	}

}