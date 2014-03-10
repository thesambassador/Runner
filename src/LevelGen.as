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
		
		public var levelHistoryType : Vector.<GenFunction>; //remembers each generated chunk type
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
		
		public var pitDepth : int = 7;
		
		public var currentChunk : Chunk; //current chunk we're operating on, generated when we create the LevelGen object
		
		public var difficulty : int;
		public var startDifficulty : int;
		public var difficultyIncrease : int = 2; //increase difficulty by 2 over the course of each level.
		
		protected var collectiblesLeft : int = 20;  //how many more collectibles can be added to the level
		protected var midBuffer : int = 5; //buffer between sections

		
		public function LevelGen(initialElevation : int, width : int, startingDifficulty:int, tileset : Class) {
			currentX = 0;
			currentY = initialElevation;
			
			difficulty = startingDifficulty;
			startDifficulty = startingDifficulty;
			
			levelHistoryType = new Vector.<GenFunction>();
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
				if (difficulty >= 11 && difficulty < 17) midBuffer = 4;
				if (difficulty >= 17 && difficulty < 21) midBuffer = 3;
				if (difficulty >= 21 && difficulty < 25) midBuffer = 2;
				if (difficulty >= 25) midBuffer = 1;
				
				var startX : int = currentX;
				var startY : int = currentY;
				var gf : GenFunction = null;
				
				//increase difficulty throughout the level
				if (currentX > (difficulty + 1 - startDifficulty) * (currentChunk.widthInTiles / (difficultyIncrease + 1))) {
					difficulty ++;
				}
				
				//get a random genfunction valid for our current difficulty
				gf = genFunctionHelper.getRandomValidFunction(difficulty, lastCategory, lastName);
				
				gf.genFunction();
				
				//check if we actually generated something (if the current X or current Y changed at all)
				if(currentX != startX || startY != currentY){
					GenFlat(midBuffer); 
				
					lastCategory = gf.category;
					lastName = gf.name;
					
					levelHistoryX.push(currentX);
					levelHistoryType.push(gf);
					
					currentChunk.safeZones.push(new FlxPoint(currentX-2, currentY));
					
					if (currentY < 10) {
						currentY = 10;
					}
					else if (currentY > CommonConstants.LEVELHEIGHT - 10) {
						currentY = CommonConstants.LEVELHEIGHT - 10;
					}

					
				}
						
			}
			
			//fill in the rest of the level with flatness
			while (currentX < currentChunk.widthInTiles) {
				var setTile : int = 1;
				
				if (currentX == currentChunk.widthInTiles - 1) setTile = 9;
				
				currentChunk.mainTiles.setTile(currentX, currentY, setTile);
				FillUnder(currentX, currentY, currentChunk.mainTiles, 4);
				
				currentX ++;
			}
			
			//do a second pass on the level and add some one-way platforms and stuff
			//AddRandomOneWayPlatforms();
			
			currentChunk.Decorate();
			
			return currentChunk;
		}
		
		protected function AddRandomOneWayPlatforms() {
			var flatSections : Array = currentChunk.FindFlatLengths(20);
			
			for (var i:int = 0; i < flatSections.length; i += 2) {
				if(FlxG.random() > 0){
					var flatStartX : int = flatSections[i];
					var flatLength : int = flatSections[i + 1];
					var flatEndX : int = flatStartX + flatLength;
					var groundHeight : int = currentChunk.heightmap[flatStartX] - 1;
					
					//randomize bottom section length
					
					var botHeight : int = 3;
					var botStartX : int = flatStartX + CommonFunctions.getRandom(5, 10);
					var botLength : int = CommonFunctions.getRandom(10, flatLength - flatStartX);
					
					currentChunk.AddOneWayPlatform(botStartX, groundHeight, botLength, botHeight);
					
					var upperLevelChance : Number = .75;
					var upperLevelX : int = botStartX + CommonFunctions.getRandom(3, 10);
					var upperLevelHeight : int = botHeight + CommonFunctions.getRandom(2, 3);
					
					while (FlxG.random() < upperLevelChance) {
						var upperLevelLength : int = CommonFunctions.getRandom(6, flatLength - upperLevelX);
						if (upperLevelLength > flatLength - upperLevelX) break;
						
						currentChunk.AddOneWayPlatform(upperLevelX, groundHeight, upperLevelLength, upperLevelHeight);
						
						upperLevelChance -= .25;
						upperLevelX = upperLevelX + CommonFunctions.getRandom(3, 10);
						upperLevelHeight = upperLevelHeight + CommonFunctions.getRandom(2, 3);
					}

				}
			}
		}
	

		
		protected function GenFlat(w:int = -1) : void {
			var width : int ;
			if(w == -1)
				width = CommonFunctions.getRandom(8, 15);
			else
				width = w;
			
			//if (width + currentX > currentChunk.widthInTiles) return;
				
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
		
		
		protected function GenGap(w:int = -1) : void {		
			
			var width : int ;
			if(w == -1)
				width = CommonFunctions.getRandom(4, 8);
			else
				width = w;

			if (currentY < CommonConstants.LEVELHEIGHT - 6) {
				for (var i : int = 0; i < width; i++) {
					var x : int = currentX + i;
					currentChunk.mainTiles.setTile(currentX + i, currentY + pitDepth, 16);
					FillUnder(currentX + i, currentY + pitDepth, currentChunk.mainTiles, 4);
						
				}
			}
			
			
			
			currentX += width;
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
		
		
		
		public function GenSpringboard() : void {
			GenFlat(2);
			var springboard : Springboard = new Springboard();
			currentChunk.AddEntityAtTileCoords(springboard, currentX - 2, currentY - 1);
		}
		
		//adds a platform of width w starting at sx,sy.  Crumble tiles will be used if crumble is specified
		public function AddPlatform(sx:int, sy:int, w:int, crumble:Boolean = false, coins:Boolean = false, alternate : Boolean = false) : void {
			for (var x:int = sx; x < sx + w; x++) {
				if (crumble) {
					var ct : CrumbleTile = new CrumbleTile();
					currentChunk.AddEntityAtTileCoords(ct, x, sy);
				}
				else {
					currentChunk.mainTiles.setTile(x, sy, 8);
				}
				if (coins == 1) {
					addCollectible(x, sy - 1);
				}
				if (coins == 2) {
					if(x % 2 == 1)
						addCollectible(x, sy - 1);
				}
			}
		}
		
		//x: x value of first collectible
		//y: elevation to start
		//  **        *
		// *  *  or  * *
		// w=4       w=3
		public function AddCoinArch(sx:int, sy:int, w:int) : void{
			if (w < 3) return;

			addCollectible(sx, sy);
			addCollectible(sx + w - 1, sy);


			var y : int = sy - 1;

			for (var x : int = sx + 1; x < sx + w - 1; x++) {
				addCollectible(x, y);
			}

		}
		
		public function AddCoinRect(left : int, top : int, right : int, bottom : int) : void {
			var save : int;
			if (left > right) {
				save = left;
				left = right;
				right = save;
			}
			if (top > bottom) {
				save = top; 
				top = bottom;
				bottom = save;
			}
			
			for (var setX:int = left; setX <= right; setX++) {
				for (var setY:int = top; setY <= bottom; setY++) {
					addCollectible(setX, setY);
				}
			}
		}
		
		public function addCollectible(x:int, y:int) : void{
			var col : Collectible = new Collectible();
			currentChunk.AddEntityAtTileCoords(col, x, y);
			collectiblesLeft --;
		}
		
		//fill all tiles under the specific tile (not including it).
		protected function FillUnder(sx:int, sy:int, tiles:FlxTilemap, fillTile:int = 4) : void {
			for (var y : int = sy + 1; y < CommonConstants.LEVELHEIGHT; y++) {
				tiles.setTile(sx, y, fillTile);
			}
		}
		//fill all tiles above the specific tile (not including it).
		protected function FillAbove(sx:int, sy:int, tiles:FlxTilemap, fillTile:int = 4) : void {
			for (var y : int = sy - 1; y >= 0; y--) {
				tiles.setTile(sx, y, fillTile);
			}
		}
		
		public function checkPreviousType() : String {
			if (levelHistoryType.length == 0) return "";
			else return levelHistoryType[levelHistoryType.length - 1].name;
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