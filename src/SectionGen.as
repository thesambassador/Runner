package  
{
	import org.flixel.FlxTilemap;
	import org.flixel.FlxU;
	import org.flixel.system.FlxTile;
	
	/**
	 * ...
	 * @author ...
	 */
	public class SectionGen 
	{
		[Embed(source = 'testTileset.png')]private static var grass:Class;

		
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
			genFunctions.push(ElevationChange);
			genFunctions.push(Gap);
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
		
		private function getRandom(min:int, max:int) {
			return Math.round(Math.random() * (max - min)) + min;
		}
		
		//begin actual terrain gen
		private function Flat() : FlxTilemap{
			var returned : FlxTilemap = new FlxTilemap();
			var width : int = getRandom(4, 10);
			
			returned.loadMap(MakeEmptySectionString(width, levelHeight), grass, CommonConstants.TILEWIDTH, CommonConstants.TILEHEIGHT); 
			returned.x = currentX;
			
			for (var x : int = 0; x < width; x++) {
				var setTile : int = 1;
				if (x == width - 1) {
					setTile = 2;
				}
				
				returned.setTile(x, currentElevation, setTile);
				for (var y : int = currentElevation + 1; y < levelHeight; y++) {
					returned.setTile(x, y, 3);
				}
			}
			
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
				
				for (var y : int = currentElevation + 1; y < levelHeight; y++) {
					returned.setTile(x, y, 3);
				}
			}
			
			currentX += width * CommonConstants.TILEWIDTH;
			return returned;
		}
		
		private function Gap() : FlxTilemap {
			var returned : FlxTilemap = new FlxTilemap();
			var width : int = getRandom(4, 8);
			
			returned.loadMap(MakeEmptySectionString(width, levelHeight), grass, CommonConstants.TILEWIDTH, CommonConstants.TILEHEIGHT); 
			returned.x = currentX;
			
			returned.setTile(width-1, currentElevation, 2);
			for (var y : int = currentElevation + 1; y < levelHeight; y++) {
				returned.setTile(width-1, y, 3);
			}
			
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
		
	}

}