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
		
		public var currentX : int; //tile coords
		public var currentY : int; //tile coords
		
		public var tileset : Class //tileset to use to generate
		
		public var genFunctions : Array; //array of level generation functions
		public var consecutiveCategories : int = 0; //number of times the current category has been generated in a row
		public var lastCategory : String = "";
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
			
			
			genFunctions = new Array();
			InitializeGenFunctions();
			
			currentChunk = new Chunk(tileset, width);
			
		}
		
		public function InitializeGenFunctions() : void{
			genFunctions.push(new GenFunction(GenFlat, 0, 10, "flat"));
			genFunctions.push(new GenFunction(GenGap, 0, 10, "gap"));
		}
		
		public function GetGenFunction(diff : int) : GenFunction {
			var validFunctions : Array = new Array();
			
			for each(var genFunct : GenFunction in genFunctions) {
				if (diff >= genFunct.minDifficulty && diff <= genFunct.maxDifficulty) {

						validFunctions.push(genFunct);
				}
			}
			
			return FlxU.getRandom(validFunctions) as GenFunction;
		}
		
		public function GenerateLevel() : Chunk {
			while (currentX < currentChunk.mainTiles.widthInTiles - endBuffer) {
				var gf : GenFunction = null;
				if (currentX > (difficulty + 1 - startDifficulty) * (currentChunk.widthInTiles / (difficultyIncrease + 1))) {
					difficulty ++;
				}
				while(gf == null){
					//get a random genfunction valid for our current difficulty
					gf = GetGenFunction(difficulty);
					
					if (gf.category == bannedCategory) { 
						gf = null;
						continue;
					}
					
					//if we generated this category last iteration, take note
					if (lastCategory == gf.category) {
						consecutiveCategories += 1;
//
					}
					else {
						consecutiveCategories = 0;
					}
					
					//now stop consecutive runs of the same function:
					if (consecutiveCategories > 0) {
						if (gf.category == "gap") gf = null;
						else if (gf.category == "changeY" && consecutiveCategories >= 2) gf = null;
						else if (gf.category == "slide"  && consecutiveCategories >= 2) gf = null;
						else if (gf.category == "hurtle"  && consecutiveCategories >= 1) gf = null;
						else if (gf.category == "enemy"  && consecutiveCategories >= 2) gf = null;
					}
					
					
				}
				if(gf.category != lastCategory) consecutiveCategories = 0;
				gf.genFunction();
				lastCategory = gf.category;
				bannedCategory = gf.bannedCategory;
				
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
				
				//if (x == currentX + width - 1) {
				//	setTile = 10;
				//}
				
				currentChunk.mainTiles.setTile(x, currentY, setTile);
				
				FillUnder(x, currentY, currentChunk.mainTiles, 4);
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
		
		public function AddSimpleMovingPlatform(sx:int, sy:int, ex:int, ey:int, maxSpeed:int = 100, minSpeed:int = 20) {	
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