package  
{
	import org.flixel.*;

	/**
	 * ...
	 * @author ...
	 */
	public class Chunk 
	{
		
		//tilemap indexes
		//main level tiles
		private static var groundTop : int = 1; //main tile that the player runs on
		private static var groundTopLeft: int = 2;
		private static var groundTopRight : int = 3;
		private static var underground : int = 4;
		private static var barrier : int = 8;
		
		//background platforms
		private static var topleft : int = 20;
		private static var topmiddle : int = 21;
		private static var topright : int = 22;
		private static var left : int = 28;
		private static var middle : int = 29;
		private static var right : int = 30;

		public var mainTiles : FlxTilemap;  //main tiles for collision
		public var bgTiles : FlxTilemap; //background tiles with no collision
		public var fgTiles : FlxTilemap; //foreground tiles with no collision
		
		public var entities : FlxGroup; //all entities (enemies, moving objects, etc)
		
		public var nextChunk : Chunk;
		
		public var tileset : Class;
		
		//constructor creates an empty chunk and adds itself to the stage
		public function Chunk(tilesetToUse : Class, width:int, height:int = -1) 
		{
			tileset = tilesetToUse;
			if (height == -1) height = CommonConstants.LEVELHEIGHT;
			
			mainTiles = new FlxTilemap();
			mainTiles.loadMap(MakeEmptySectionString(width, height), tileset, CommonConstants.TILEWIDTH, CommonConstants.TILEHEIGHT);
			
			bgTiles = new FlxTilemap();
			bgTiles.loadMap(MakeEmptySectionString(width, height), tileset, CommonConstants.TILEWIDTH, CommonConstants.TILEHEIGHT);
			
			fgTiles = new FlxTilemap();
			fgTiles.loadMap(MakeEmptySectionString(width, height), tileset, CommonConstants.TILEWIDTH, CommonConstants.TILEHEIGHT);
			
			entities = new FlxGroup();
		}
		
		//basic function to create the string that Flixel uses to initialize a FlxTilemap
		private function MakeEmptySectionString(width:int, height:int) : String {
			var data : Array = new Array();
			
			for (var i:int = 0; i < width * height; i++) {
				data.push("0");
			}
			return FlxTilemap.arrayToCSV(data, width);
		}
		
		//sets the world x coordinate of the tileset
		public function SetX(x:int) : void {
			mainTiles.x = x;
			bgTiles.x = x;
			fgTiles.x = x;
			
			for each(var entity:FlxSprite in entities.members) {
				entity.x += x;
			}
		}
		
		//this will add scenery and non-gameplay related stuff
		public function Decorate() : void {
			
			//add the rounded corners of the grass as needed:
			var topGrassTiles : Array = mainTiles.getTileInstances(1);
			if (topGrassTiles != null && topGrassTiles.length > 0) {
				for each (var tile: int in topGrassTiles) {
					if (tile % mainTiles.width == 0 || mainTiles.getTileByIndex(tile-1) == 0) {
						mainTiles.setTileByIndex(tile, 2);
					}
					else if (tile % width == width - 1 || mainTiles.getTileByIndex(tile + 1) == 0) {
						mainTiles.setTileByIndex(tile, 3);
					}
				}
			}
			
			RandomizeGroundTiles();
		}
		
		public function get width() : Number {
			return mainTiles.width;
		}
		
		public function get widthInTiles() : Number {
			return mainTiles.widthInTiles;
		}
		
		public function get endElevation() : Number {
			var x : int = mainTiles.widthInTiles - 1;
			for (var y : int = 0; y < mainTiles.heightInTiles; y++) {
				if (mainTiles.getTile(x, y) == groundTop) {
					return y;
				}
			}
			return -1;
		}
		
		//put a 1-way platform of width w and height h at x,y.  x,y is the bottom-left corner of the 1-way platform
		public function AddOneWayPlatform(x:int, y:int, w:int, h:int) : void {

			
			for (var setX:int = x; setX < x + w; setX++) {
				for (var setY:int = y; setY > y - h; setY--) {
					//left tiles
					if (setX == x) {
						if (setY == y - h + 1) {
							mainTiles.setTile(setX, setY, topleft);
							mainTiles.setTileProperties(mainTiles.getTile(setX, setY), FlxObject.UP); 
						}
						else {
							mainTiles.setTile(setX, setY, left);
							mainTiles.setTileProperties(mainTiles.getTile(setX, setY), FlxObject.NONE);
						}
					}
					//middle tiles
					else if (setX < x + w - 1) {
						if (setY == y - h + 1) {
							mainTiles.setTile(setX, setY, topmiddle);
							mainTiles.setTileProperties(mainTiles.getTile(setX, setY), FlxObject.UP); 
						}
						else {
							mainTiles.setTile(setX, setY, middle);
							mainTiles.setTileProperties(mainTiles.getTile(setX, setY), FlxObject.NONE);
						}
					}
					//right tiles
					else{
						if (setY == y - h + 1) {
							mainTiles.setTile(setX, setY, topright);
							mainTiles.setTileProperties(mainTiles.getTile(setX, setY), FlxObject.UP); 
						}
						else {
							mainTiles.setTile(setX, setY, right);
							mainTiles.setTileProperties(mainTiles.getTile(setX, setY), FlxObject.NONE);
						}
					}
				}
			}
			FlxG.log("Platform at x:" + x + ", y:" + y + ", w:" + w + ", h:" + h); 
		}
		
		public function FillSolid(x:int, y:int, w:int, h:int, fillBlock : int = 17) : void {
			
			for (var setX:int = x; setX < x + w; setX++) {
				for (var setY:int = y; setY < y + h; setY++) {
					mainTiles.setTile(setX, setY, fillBlock);
				
				}
			}
		}
		
		public function AddEntityAtTileCoords(entity:FlxSprite, x : int, y : int) : void{
			this.entities.add(entity);
			entity.x = this.mainTiles.x + x * CommonConstants.TILEWIDTH;
			entity.y = this.mainTiles.y + y * CommonConstants.TILEHEIGHT;
		}
		
		//There are 3 different "ground" tiles and 3 differnet "underground" tiles The ChunkGen will generate a 1 for ground or 4 for underground
		//This function goes through and randomly distributes the different ground tiles, varying the look of the level
		//Ground = 1-3
		//Underground = 4-6
		private function RandomizeGroundTiles() : void {
			//get all tiles with index 1
			var groundTiles : Array = mainTiles.getTileInstances(4);
			var tileIndex : int;
			
			for each(tileIndex in groundTiles) {
				mainTiles.setTileByIndex(tileIndex, getRandom(4, 6));
			}
			

			
		}
		
	
			
		private function getRandom(min:int, max:int) : int {
			return Math.round(Math.random() * (max - min)) + min;
		}
	}

}