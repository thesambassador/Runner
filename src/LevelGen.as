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
		public static var endBuffer : int = 15; //stop generating level pieces once we get to total width of the level minus endBuffer.
		
		public var levelHistoryType : Array; //remembers each generated chunk type
		public var levelHistoryX : Array // remembers each generated chunk's starting x position
		
		public var currentX : int; //tile coords
		public var currentY : int; //tile coords
		public var backgroundPlatformHeight : int = -1; //we draw the "background platform" stuff when this is not -1 in the "base" functions
		
		public var tileset : Class //tileset to use to generate

		public var genFunctionHelper : GenFunctionHelper;
		
		public var consecutiveCategories : int = 0; //number of times the current category has been generated in a row
		public var lastCategory : String = "";
		public var lastName : String = "";
		public var bannedCategory : String = "";
		
		public var currentChunk : Chunk; //current chunk we're operating on, generated when we create the LevelGen object
		
		public var difficulty : int;
		public var startDifficulty : int;
		public var difficultyIncrease : int = 2; //increase difficulty by 2 over the course of this level.
		
		protected var collectiblesLeft : int = 20;  //how many more collectibles can be added to the level
		protected var midBuffer : int = 5; //buffer between sections
		
		public function LevelGen(initialElevation : int, width : int, startingDifficulty:int, tileset : Class) {
			currentX = 0;
			currentY = initialElevation;
			
			difficulty = startingDifficulty;
			startDifficulty = startingDifficulty;
			//diffWidth = width / difficultyIncrease;
			
			levelHistoryType = new Array();
			levelHistoryX = new Array();
			
			genFunctionHelper = new GenFunctionHelper();
			InitializeGenFunctions();
			
			currentChunk = new Chunk(tileset, width);
			
		}
		
		public function InitializeGenFunctions() : void {
			genFunctionHelper.addFunction("Flat", GenFlat, 0, 10, "flat");
			genFunctionHelper.addFunction("Gap", GenGap, 0, 10, "gap");
		}
		
		public function GenerateLevel() : Chunk {
			while (currentX < currentChunk.mainTiles.widthInTiles - endBuffer) {
				var startX : int = currentX;
				var gf : GenFunction = null;
				if (currentX > (difficulty + 1 - startDifficulty) * (currentChunk.widthInTiles / (difficultyIncrease + 1))) {
					difficulty ++;
				}
				//get a random genfunction valid for our current difficulty
				gf = genFunctionHelper.getRandomValidFunction(difficulty, "", lastName);

				levelHistoryX.push(currentX);
				levelHistoryType.push(gf.category);
				
				gf.genFunction();
				
				//check to see if we actually generated a level section
				
				lastCategory = gf.category;
				lastName = gf.name;
				
				if (currentY <= 0) {
					currentY = 3;
				}
				else if (currentY > CommonConstants.LEVELHEIGHT) {
					currentY = CommonConstants.LEVELHEIGHT - 3;
				}
				currentChunk.safeZones.push(new FlxPoint(currentX, currentY));
				GenFlat(midBuffer); 
			}
			
			//fill in the rest of the level with flatness
			while (currentX < currentChunk.widthInTiles) {
				var setTile : int = 1;
				
				if (currentX == currentChunk.widthInTiles - 1) setTile = 9;
				
				currentChunk.mainTiles.setTile(currentX, currentY, setTile);
				FillUnder(currentX, currentY, currentChunk.mainTiles, 4);
				
				currentX ++;
			}
			
			currentChunk.Decorate();
			
			return currentChunk;
		}
	

		protected function GenFlat(w:int = -1) : void {
			var width : int ;
			if(w == -1)
				width = CommonFunctions.getRandom(8, 15);
			else
				width = w;
			
			for (var x : int = currentX; x < width + currentX; x++) {
				var setTile : int = 1;
				
				currentChunk.mainTiles.setTile(x, currentY, setTile);
				
				FillUnder(x, currentY, currentChunk.mainTiles, 4);
				
				//adds background tiles from the ground up to the background height
				if (backgroundPlatformHeight != -1) {
					currentChunk.FillSolidRect(currentChunk.bgTiles, x, backgroundPlatformHeight, x, currentY, 20);
				}
			}
			currentX += width;
			
			
		}
		
		protected function GenElevationChange() : void{
			if (currentY > CommonConstants.LEVELHEIGHT - 2) {
				currentY += CommonFunctions.getRandom( -2, -1);
			}
			else if (currentY <= 2) {
				currentY += CommonFunctions.getRandom(2, 1);
			}
			else {
				currentY += CommonFunctions.getRandom( -2, 2);
			}
			GenFlat(2);
		}
		
		protected function GenGap(w:int = -1) : void {		
			
			var width : int ;
			if(w == -1)
				width = CommonFunctions.getRandom(4, 8);
			else
				width = w;
	
			
			if (currentY < CommonConstants.LEVELHEIGHT - 6) {
				var pitDepth : int = 7;
				for (var i : int = 0; i < width; i++) {
					currentChunk.mainTiles.setTile(currentX + i, currentY + pitDepth, 16);
					FillUnder(currentX + i, currentY + pitDepth, currentChunk.mainTiles, 4);
				}
			}
				
			//FillUnder(currentX + width - 1, currentY, currentChunk.mainTiles, 4);
			
			currentX += width;
		}
		
		//this is the same as flat, but a bit wider and adds multiple "levels" that the player can jump onto for some variation
		protected function GenMultiLevel(w:int = -1) : void {
			var startX : int = currentX;
			var width : int ;
			if(w == -1)
				width = CommonFunctions.getRandom(10, 15);
			else
				width = w;
				
			GenFlat(width);
			
			//number of additional levels (not including the ground)
			var numLevels : int = CommonFunctions.getRandom(1, 3);
			
			//higher levels must be generated first, each level will be a random width and height
			while (numLevels > 0) {
				var genX : int = CommonFunctions.getRandom(startX, startX + 2);
				var h : int = numLevels * CommonConstants.JUMPHEIGHT - CommonFunctions.getRandom(0, 1);
				var w : int = CommonFunctions.getRandom(2, width-2);
				currentChunk.AddOneWayPlatform(genX, currentY - 1, w, h);
					
				var spacing : int = CommonFunctions.getRandom(1, 4);
					
				genX = genX + w + spacing;
				numLevels --;
			}

		}
		
		

		
		public function AddSimpleMovingPlatform(sx:int, sy:int, ex:int, ey:int, maxSpeed:int = 100, minSpeed:int = 20) : void {	
			var sxReal : int = sx * CommonConstants.TILEWIDTH;
			var syReal : int = sy * CommonConstants.TILEHEIGHT;
			var exReal : int = ex * CommonConstants.TILEWIDTH;
			var eyReal : int = ey * CommonConstants.TILEHEIGHT;
			
			var mp : MovingPlatform = new MovingPlatform();
			mp.velocity.x = 0;
			mp.velocity.y = 0;
			mp.x = sxReal;
			mp.y = syReal;
			mp.topSpeed = maxSpeed;
			mp.minSpeed = minSpeed;
			
			var path : FlxPath = new FlxPath();
			path.add(sxReal, syReal);
			path.add(exReal, eyReal);
			
			mp.path = path;
			
			//mp.followPath(path, maxSpeed, FlxObject.PATH_LOOP_BACKWARD);
			
			currentChunk.AddEntityAtTileCoords(mp, sx, sy);
			
		}
		
		public function addCollectible(x:int, y:int) : void{
			var col : Collectible = new Collectible();
			currentChunk.AddEntityAtTileCoords(col, x, y);
			collectiblesLeft --;
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
		
		protected function CalcMaxJumpDistance(y:int) : int {
			
			if (y >= 0) return 10;
			
			var a : Number = CommonConstants.JUMPHEIGHT / Math.pow(CommonConstants.JUMPLENGTH, 2);
			var returned : int =  Math.sqrt((y + CommonConstants.JUMPHEIGHT) / a) as int;
			

			return returned;
		}

	}
	
}