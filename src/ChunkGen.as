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
		
		public function ChunkGen() 
		{
			currentX = 0;
			currentElevation = CommonConstants.LEVELHEIGHT - 1
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
		private function GetValidFunctions() : Array {
			var functions : Array = new Array();
			
			functions.push(GenFlat);
			functions.push(GenElevationChange);
			
			return functions;
		}
		
		private function GenFlat(w:int = -1) : Chunk {
			var width : int ;
			if(w = -1)
				width = getRandom(4, 10);
			else
				width = w;
			
			var returned : Chunk = new Chunk(width);
			
			for (var x : int = 0; x < width; x++) {
				var setTile : int = 1;
				returned.mainTiles.setTile(x, currentElevation, setTile);
				
				FillUnder(x, currentElevation, returned.mainTiles, 4);
			}
			
			
			return returned;
		}
		
		private function GenElevationChange() : Chunk {
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
		
		//fill all tiles under the specific tile.
		private function FillUnder(sx:int, sy:int, tiles:FlxTilemap, fillTile:int = 1) {
			for (var y : int = sy + 1; y < CommonConstants.LEVELHEIGHT; y++) {
				tiles.setTile(sx, y, fillTile);
			}
		}
		
		private function getRandom(min:int, max:int) {
			return Math.round(Math.random() * (max - min)) + min;
		}
	}

}