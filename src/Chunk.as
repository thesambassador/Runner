package  
{
	import org.flixel.*;

	/**
	 * ...
	 * @author ...
	 */
	public class Chunk 
	{
		[Embed(source = '../resources/img/grasstileset.png')]private static var tileset:Class;

		public var mainTiles : FlxTilemap;  //main tiles for collision
		public var bgTiles : FlxTilemap; //background tiles with no collision
		public var fgTiles : FlxTilemap; //foreground tiles with no collision
		
		public var allLayers : FlxGroup;
		
		public var nextChunk : Chunk;
		
		//constructor creates an empty chunk and adds itself to the stage
		public function Chunk(width:int) 
		{
			
			mainTiles = new FlxTilemap();
			mainTiles.loadMap(MakeEmptySectionString(width, CommonConstants.LEVELHEIGHT), tileset, CommonConstants.TILEWIDTH, CommonConstants.TILEHEIGHT);
			
			bgTiles = new FlxTilemap();
			bgTiles.loadMap(MakeEmptySectionString(width, CommonConstants.LEVELHEIGHT), tileset, CommonConstants.TILEWIDTH, CommonConstants.TILEHEIGHT);
			
			fgTiles = new FlxTilemap();
			fgTiles.loadMap(MakeEmptySectionString(width, CommonConstants.LEVELHEIGHT), tileset, CommonConstants.TILEWIDTH, CommonConstants.TILEHEIGHT);
			
			allLayers = new FlxGroup();
			allLayers.add(bgTiles);
			allLayers.add(mainTiles);
			allLayers.add(fgTiles);
		}
		
		//basic function to create the string that Flixel uses to initialize a FlxTilemap
		private function MakeEmptySectionString(width:int, height:int) : String {
			var data : Array = new Array();
			
			for (var i:int = 0; i < width * height; i++) {
				data.push("0");
			}
			
			return FlxTilemap.arrayToCSV(data, width);
			
		}
		
		public function SetX(x:int) {
			mainTiles.x = x;
			bgTiles.x = x;
			fgTiles.x 
		}
		
		//this will add scenery and non-gameplay related stuff
		public function Decorate() {
			RandomizeGroundTiles();
		}
		
		//There are 3 different "ground" tiles and 3 differnet "underground" tiles The ChunkGen will generate a 1 for ground or 4 for underground
		//This function goes through and randomly distributes the different ground tiles, varying the look of the level
		//Ground = 1-3
		//Underground = 4-6
		private function RandomizeGroundTiles() {
			//get all tiles with index 1
			var groundTiles : Array = mainTiles.getTileInstances(1);
			
			for each(var tileIndex : int in groundTiles) {
				mainTiles.setTileByIndex(tileIndex, getRandom(1, 3));
			}
			
			groundTiles = mainTiles.getTileInstances(4);
			
			for each(var tileIndex : int in groundTiles) {
				mainTiles.setTileByIndex(tileIndex, getRandom(4, 6));
			}
			
			
		}
			
		private function getRandom(min:int, max:int) {
			return Math.round(Math.random() * (max - min)) + min;
		}
	}

}