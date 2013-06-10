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
				levelHistoryType.push(gf);
				
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
			AddRewardPathways();
			
			return currentChunk;
		}
	
		//goes through and adds harder paths to parts of the level to add variety
		protected function AddRewardPathways() : void {
			var validIndices : Array = new Array();
			
			//2 high coin areas per level
			//find valid places for higher coins (enemies, springboards, drops, hurtles)
			for (var i : int = 0; i < levelHistoryType.length; i++) {
				var gf : GenFunction = levelHistoryType[i] as GenFunction;
				if (gf.category == "enemy" || gf.category == "yDown" || gf.category == "hurtle") {
					validIndices.push(i);
				}
			}
			
			//add some higher coins to a random 3 of these
			for (var i : int = 0; i < 3; i++) {
				if(validIndices.length > 0){
					var index = FlxG.getRandom(validIndices);
					AddHighCoins(index);
					validIndices.splice(validIndices.lastIndexOf(index), 1);
				}
			}

			//1 simple high area with coins
			
			//2 medium reward pathways
			
			//1 hard reward pathway
		}
		
		protected function AddHighCoins(index : int) {
			var gf : GenFunction = levelHistoryType[index] as GenFunction;
			var startX : int = levelHistoryX[index] as int;
			var elevation : int = currentChunk.heightmap[startX];
			
			if (gf.category == "enemy") {
				AddCoinArch(startX, elevation - 7, 4);
			}
			else if (gf.name == "AdvancedHurtle") {
				AddCoinArch(startX + 12, elevation - 9, 4);
			}
			else if (gf.name == "Hurtle") {
				AddCoinArch(startX + 5, elevation - 7, 3);
			}
			else if (gf.category == "yDown") {
				if(startX > 0)
					elevation = currentChunk.heightmap[startX - 1];
				AddCoinArch(startX + 3, elevation - 4, 3);
			}
			
			
			
			
			
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
		public function AddPlatform(sx:int, sy:int, w:int, crumble:Boolean = false) {
			for (var x:int = sx; x < sx + w; x++) {
				if (crumble) {
					var ct : CrumbleTile = new CrumbleTile();
					currentChunk.AddEntityAtTileCoords(ct, x, sy);
				}
				else {
					currentChunk.mainTiles.setTile(x, sy, 8);
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