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
		public static var groundTop : int = 1; //main tile that the player runs on
		public static var groundTopLeft: int = 2;
		public static var groundTopRight : int = 3;
		public static var underground : int = 4;
		public static var barrier : int = 8;
		public static var spike : int = 16;
		public static var oneWayPlatform : int = 14;
		
		//background platforms
		public static var topleft : int = 11;
		public static var topmiddle : int = 12;
		public static var topright : int = 13;
		public static var left : int = 19;
		public static var middle : int = 20;
		public static var right : int = 21;
		
		//decorative tiles
		public static var bgGrass : int = 24;
		public static var bushLeft : int = 28;
		
		public static var treeBotLeft : int = 40;
		public static var treeBotMid : int = 41;
		public static var treeBotRight : int = 42;
		
		public static var treeLeft : int = 32;
		public static var treeMid : int = 33;
		public static var treeRight : int = 34;

		public var mainTiles : FlxTilemap;  //main tiles for collision
		public var bgTiles : FlxTilemap; //background tiles with no collision
		public var fgTiles : FlxTilemap; //foreground tiles with no collision
		
		public var entities : FlxGroup; //all entities (enemies, moving objects, etc)
		
		public var safeZones : Array; //array of safe places to replace the character if he dies
		
		public var nextChunk : Chunk;
		
		public var tileset : Class;
		
		private var _heightmap : Array;
		
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
			
			mainTiles.setTileProperties(topleft, FlxObject.UP);
			mainTiles.setTileProperties(topmiddle, FlxObject.UP);
			mainTiles.setTileProperties(topright, FlxObject.UP);
			mainTiles.setTileProperties(oneWayPlatform, FlxObject.UP);
			mainTiles.setTileProperties(left, FlxObject.NONE);
			mainTiles.setTileProperties(middle, FlxObject.NONE);
			mainTiles.setTileProperties(right, FlxObject.NONE);
			mainTiles.setTileProperties(spike, FlxObject.ANY, CommonFunctions.killPlayer);
			
			safeZones = new Array();
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
			
			for each(var entity:Entity in entities.members) {
				entity.setX(x);
				entity.origPosX += x;
			}
		}
		
		//this will add scenery and non-gameplay related stuff
		public function Decorate() : void {


			//PlaceTrees();
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
					else {
						//randomly add some grass
						var grassTile : uint = CommonFunctions.getRandom(-1, 2);
						if (grassTile >= 0) {
							fgTiles.setTileByIndex(tile-mainTiles.widthInTiles, bgGrass + grassTile + 1);
						}
						//randomly add some bushes
						var shouldPlace : Number = Math.random();
						if (shouldPlace < .1) {
							var indexLeft : int = tile-mainTiles.widthInTiles;
							var indexRight : int = tile-mainTiles.widthInTiles + 1;
							
							if (bgTiles.getTileByIndex(indexLeft - 1) == 0 && bgTiles.getTileByIndex(indexLeft) == 0) {
								if(mainTiles.getTileByIndex(indexLeft - 1) == 0 && mainTiles.getTileByIndex(indexLeft) == 0){
									bgTiles.setTileByIndex(indexLeft, bushLeft);
									bgTiles.setTileByIndex(indexRight, bushLeft + 1);
								}
							}
						}
					}
					
				}
			}
			//add rounded corners/edges to background tiles
			var bgPlatformTiles : Array = bgTiles.getTileInstances(20);
			if (bgPlatformTiles != null && bgPlatformTiles.length > 0) {
				for each (tile in bgPlatformTiles) {
					
					//check the tile above us to see if it's empty (top of the background)
					var indexAbove : int = tile - widthInTiles;
					var indexRight : int = tile + 1;
					var indexLeft : int = tile - 1;
					
					var setTile : int = middle;
					
					if (bgTiles.getTileByIndex(indexAbove) == 0 && mainTiles.getTileByIndex(indexAbove) == 0) {
						setTile -= 8;
					}
					
					if (bgTiles.getTileByIndex(indexLeft) == 0 && mainTiles.getTileByIndex(indexLeft) == 0) {
						setTile -= 1;
					}
					
					if (bgTiles.getTileByIndex(indexRight) == 0 && mainTiles.getTileByIndex(indexRight) == 0) {
						setTile += 1;
					}
					
					//if it's the top, we want the player to be able to collide with it
					if (setTile == topright || setTile == topleft || setTile == topmiddle) {
						if(mainTiles.getTileByIndex(tile) == 0){
							mainTiles.setTileByIndex(tile, setTile);
							bgTiles.setTileByIndex(tile, 0);
						}
					}
					//otherwise, we just change the background
					else {
						bgTiles.setTileByIndex(tile, setTile);
					}
				}
			}
			
			
			
			
			RandomizeGroundTiles();
		}
		
		public function PlaceTrees() : void {
			var topGrassTiles : Array = mainTiles.getTileInstances(1);
			if (topGrassTiles != null && topGrassTiles.length > 0) {
				for each (var tile: int in topGrassTiles) {
					var treeWidth : int = CommonFunctions.getRandom(3, 7);
					if (IsClear(bgTiles, tile - widthInTiles, treeWidth) && Math.random() < .05) {
						var start:int = tile-widthInTiles;
						//place tree
						var yStart : int = start / widthInTiles;
						var xStart : int = start % widthInTiles - 1;
						for (var y : int = yStart; y > 0; y--) {
							for (var x:int = xStart; x < xStart + treeWidth; x++ ) {
								var setTile : int = 32;
								if (x != xStart) {
									setTile += 1;
								}
								if (x == xStart + treeWidth - 1) {
									setTile += 1;
								}
								if (y == yStart) {
									setTile += 8;
								}
								bgTiles.setTile(x, y, setTile);
							}
						}
						
					}
				}
			}
		}
		
		public function IsClear(tilemap : FlxTilemap, startIndex : int, width:int) : Boolean{
			var tile : int;
			for (var i:int = startIndex; i < startIndex + width; i++) {
				if (i % widthInTiles == 0) return false;
				if (tilemap.getTileByIndex(i) != 0) return false;
			}
			return true;
		}
		
		public function GetHeightmap() : Array {
			var returned : Array = new Array(widthInTiles);
			var foundHeight : Boolean;
			
			for (var tx:int = 0; tx < widthInTiles; tx++) {
				foundHeight = false;
				for (var ty :int = 0; ty < CommonConstants.LEVELHEIGHT; ty++) {
					var tileat : uint = mainTiles.getTile(tx, ty);
					if (tileat == groundTop || tileat == groundTopLeft || tileat == groundTopRight) {
						returned[tx] = ty;
						foundHeight = true;
					}
				}
				if (!foundHeight) {
					returned[tx] = -1;
				}
			}
			return returned;
		}
		
		public function get heightmap() : Array {
			if (_heightmap == null) {
				_heightmap = GetHeightmap();
			}
			return _heightmap;
		}
		
		public function get width() : Number {
			return mainTiles.width;
		}
		
		public function get x() : Number {
			return mainTiles.x;
		}
		
		public function get widthInTiles() : Number {
			return mainTiles.widthInTiles;
		}
		
		public function tileXToRealX(tx:int) : Number {

			return tx * CommonConstants.TILEWIDTH + this.x;
			
		}
		
		public function get endElevation() : Number {
			var x : int = mainTiles.widthInTiles - 2;
			for (var y : int = 0; y < mainTiles.heightInTiles; y++) {
				if (mainTiles.getTile(x, y) != 0) {
					var tile : int = mainTiles.getTile(x, y);
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

						}
						else {
							mainTiles.setTile(setX, setY, left);

						}
					}
					//middle tiles
					else if (setX < x + w - 1) {
						if (setY == y - h + 1) {
							mainTiles.setTile(setX, setY, topmiddle);

						}
						else {
							mainTiles.setTile(setX, setY, middle);

						}
					}
					//right tiles
					else{
						if (setY == y - h + 1) {
							mainTiles.setTile(setX, setY, topright);

						}
						else {
							mainTiles.setTile(setX, setY, right);

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
		
		//fills between left (inclusive) and right (exclusive), top(inclusive) and bottom(exclusive)
		//this should work even if you pass in "backwards" values (ie, left < right, top < bottom, etc)
		public function FillSolidRect(tileset : FlxTilemap, left : int, top : int, right : int, bottom : int, fillBlock : int) : void {

			if (left > right) {
				var save : int = left;
				left = right;
				right = save;
			}
			if (top > bottom) {
				var save : int = top; 
				top = bottom;
				bottom = save;
			}
			
			for (var setX:int = left; setX <= right; setX++) {
				for (var setY:int = top; setY <= bottom; setY++) {
					tileset.setTile(setX, setY, fillBlock);
				}
			}
		}
		
		public function AddEntityAtTileCoords(entity:Entity, x : int, y : int) : void{
			this.entities.add(entity);
			var targetX : Number = this.mainTiles.x + x * CommonConstants.TILEWIDTH;
			var targetY : Number = entity.y = this.mainTiles.y + y * CommonConstants.TILEHEIGHT;
			entity.SetInitialPosition(targetX, targetY);
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
		
		public static function GenFlatChunk(width : int, height : int, tileset : Class) : Chunk{
			var returned : Chunk = new Chunk(tileset, width, CommonConstants.LEVELHEIGHT);
			
			for (var x : int = 0; x < width; x++) {
				var setTile : int = 1;
				
				//if (x == currentX + width - 1) {
				//	setTile = 10;
				//}
				
				returned.mainTiles.setTile(x, height, setTile);
				
				FillUnder(x, height, returned.mainTiles, 4);
			}
			returned.safeZones.push(new FlxPoint(returned.widthInTiles - 2, height));
			return returned;
		}
		
		public static function FillUnder(sx:int, sy:int, tiles:FlxTilemap, fillTile:int = 1) : void {
			for (var y : int = sy + 1; y < CommonConstants.LEVELHEIGHT; y++) {
				tiles.setTile(sx, y, fillTile);
			}
		}
	}

}