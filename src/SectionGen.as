package  
{
	import org.flixel.FlxTilemap;
	import org.flixel.FlxU;
	import org.flixel.system.FlxTile;
	import org.flixel.FlxObject;
	
	/**
	 * ...
	 * @author ...
	 */
	public class SectionGen 
	{
		[Embed(source = '../resources/img/mario_tileset_basic.png')]private static var grass:Class;

		
		private var levelHeight : Number;
		
		public var currentElevation : Number;
		public var currentX : Number;
		
		private var availableTerrain : Array;
		
		private var initialFlat : int = 4;
		private var genFunctions : Array;
		
		public function SectionGen(elevation:Number) 
		{
			currentX = 0;
			currentElevation = elevation;
			levelHeight = CommonConstants.LEVELHEIGHT;
			
			genFunctions = new Array();
			genFunctions.push(Flat);
			genFunctions.push(Flat);
			genFunctions.push(FlatBridge);
			genFunctions.push(ElevationChange);
			genFunctions.push(ElevationChange);
			genFunctions.push(ElevationChange);
			genFunctions.push(ElevationChange);
			genFunctions.push(SmallGap);
			genFunctions.push(SmallGap);
			genFunctions.push(LargeGap);
		}
		
		public function GenerateSection() : FlxTilemap {
			//initially only generate flat terrain
			if (initialFlat > 0) {
				initialFlat -= 1;
				return Flat();
			}
			else {
				var toUse : Function = FlxU.getRandom(genFunctions) as Function;
				
				var newSect : FlxTilemap = toUse();
				if (newSect != null) {
					return newSect;
				}
				else return GenerateSection();
			}
		}
		
		//begin actual terrain gen
		private function Flat() : FlxTilemap{
			var returned : FlxTilemap = new FlxTilemap();
			var width : int = getRandom(4, 10);
			
			returned.loadMap(MakeEmptySectionString(width, levelHeight), grass, CommonConstants.TILEWIDTH, CommonConstants.TILEHEIGHT); 
			returned.x = currentX;
			
			for (var x : int = 0; x < width; x++) {
				var setTile : int = 1;
				returned.setTile(x, currentElevation, setTile);
				
				FillUnder(x, currentElevation, returned);
			}
			
			//maybe put a bush or a pipe on it
			var maybe : int = FlxU.getRandom([0, 0, 0, 1, 2]) as int;
			if (maybe == 1) {
				var bushX : int = getRandom(2, width - 3);
				AddBush(bushX, currentElevation - 1, returned);
			}
			else if (maybe == 2) {
				var pipeX : int = getRandom(2, width - 3);
				AddPipe(pipeX, currentElevation - 1, returned);
			}
			
			currentX += width * CommonConstants.TILEWIDTH;
			return returned;
		}
		
		private function FlatBridge() : FlxTilemap {
			var returned : FlxTilemap = new FlxTilemap();
			var width : int = getRandom(4, 10);
			
			returned.loadMap(MakeEmptySectionString(width, levelHeight), grass, CommonConstants.TILEWIDTH, CommonConstants.TILEHEIGHT); 
			returned.x = currentX;
			
			for (var x : int = 0; x < width - 1; x++) {
				var setTile : int = 4;

				returned.setTile(x, currentElevation, setTile);
				returned.setTile(x, currentElevation - 1, 15);
				returned.setTileProperties(returned.getTile(x, currentElevation - 1), FlxObject.NONE);

			}
			FillUnder(width - 1, currentElevation-1, returned);
			
			currentX += width * CommonConstants.TILEWIDTH;
			return returned;
		}
		
		private function ElevationChange() : FlxTilemap {
			var returned : FlxTilemap = new FlxTilemap();
			
			//figure out width of the change and how much to go up or down
			var width : int = 2; //weird behavior when this was 1
			var height : int = getRandom(-2, 2);
			if (currentElevation + height > CommonConstants.LEVELHEIGHT - 1) {
				height = -1
			}
			else if (currentElevation + height < 0) {
				height = 1;
			}
			
			
			//if height, for some reason, is 0, just set it to -1
			if (height == 0 && currentElevation > 1) {
				height = -1;
			}

			
			//create our empty map
			var test : String = MakeEmptySectionString(width, levelHeight);
			returned.loadMap(MakeEmptySectionString(width, levelHeight), grass, CommonConstants.TILEWIDTH, CommonConstants.TILEHEIGHT); 
			returned.x = currentX;
			
			for (var x : int = 0; x < width; x++) {
				if (height <= -2) {
					currentElevation -= 2;
					height += 2;
				}
				else if (height >= 2) {
					currentElevation += 2;
					height -= 2;
				}
				else{
					currentElevation += height;
					height += (-height);
				}
				
				if (x == width - 1) {
					returned.setTile(x, currentElevation, 2);
				}
				else{
					returned.setTile(x, currentElevation, 1);
				}
				
				FillUnder(x, currentElevation, returned);
			}
			
			currentX += width * CommonConstants.TILEWIDTH;
			return returned;
		}
		
		private function SmallGap() : FlxTilemap {		
			
			var returned : FlxTilemap = new FlxTilemap();
			var width : int = getRandom(5, 12);
			var endWidth : int = getRandom(3, 4);
			
			returned.loadMap(MakeEmptySectionString(width, levelHeight), grass, CommonConstants.TILEWIDTH, CommonConstants.TILEHEIGHT); 
			returned.x = currentX;
			
			for (var x : int = width - endWidth; x < width; x++) {
				FillUnder(x, currentElevation - 1, returned);
			}
			
			currentX += width * CommonConstants.TILEWIDTH;

			return returned;
		}
		
		private function LargeGap() : FlxTilemap {
			var returned : FlxTilemap = new FlxTilemap();
			var width : int = getRandom(10, 25);
			
			returned.loadMap(MakeEmptySectionString(width, levelHeight), grass, CommonConstants.TILEWIDTH, CommonConstants.TILEHEIGHT); 
			returned.x = currentX;
			
			for (var y : int = currentElevation; y < levelHeight; y++) {
				returned.setTile(width-1, y, 1);
			}
			
			//add some platforms:
			
			
			
			AddSpacedPlatforms(returned);
			
			currentX += width * CommonConstants.TILEWIDTH;

			return returned;
		}
		
		//helper functions
		private function MakeEmptySectionString(width:int, height:int) : String {
			var data : Array = new Array();
			
			for (var i:int = 0; i < width * height; i++) {
				data.push("0");
			}
			
			return FlxTilemap.arrayToCSV(data, width);
		}
		
		private function getRandom(min:int, max:int) {
			return Math.round(Math.random() * (max - min)) + min;
		}
		
		private function FillUnder(sx:int, sy:int, tiles:FlxTilemap, fillTile:int = 1) {
			for (var y : int = sy + 1; y < levelHeight; y++) {
				tiles.setTile(sx, y, fillTile);
			}
		}
		
		private function AddPlatform(sx:int, sy:int, width:int, tiles:FlxTilemap) {
			
			tiles.setTile(sx, sy, 5);
			for (var x:int = sx + 1; x < sx + width - 1; x++) {
				tiles.setTile(x, sy, 6);
			}
			tiles.setTile(sx+width-1, sy, 7);
			
		}
		
		private function AddSpacedPlatforms(tiles:FlxTilemap) {
			var width : int = tiles.widthInTiles;
			
			var currentX : int = 2;
			
			
			while (width > 6) {
				var platformWidth : int = getRandom(2, 4);
				
				if (currentX + platformWidth + 1 >= tiles.widthInTiles) {
					break;
				}
				
				AddPlatform(currentX, currentElevation, platformWidth, tiles);
				
				currentX += platformWidth + getRandom(2, 4);
				
				width -= platformWidth;
			}
		}
		
		private function AddBush(sx:int, sy:int, tiles:FlxTilemap) {
			if (sx + 2 >= tiles.width) {
				return;
			}
			tiles.setTile(sx, sy, 12);
			tiles.setTile(sx+1, sy, 13);
			tiles.setTile(sx+2, sy, 14);
			tiles.setTileProperties(tiles.getTile(sx, sy), FlxObject.NONE);
			tiles.setTileProperties(tiles.getTile(sx+1, sy), FlxObject.NONE);
			tiles.setTileProperties(tiles.getTile(sx+2, sy), FlxObject.NONE);
		}
		
		private function AddPipe(sx:int, sy:int, tiles:FlxTilemap) {
			tiles.setTile(sx, sy, 10);
			tiles.setTile(sx+1, sy, 11);
			tiles.setTile(sx, sy-1, 8);
			tiles.setTile(sx+1, sy-1, 9);
		}
	}

}