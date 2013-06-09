package 
{
	import org.flixel.FlxG;
	import org.flixel.FlxPath;
	import org.flixel.FlxObject;
	/**
	 * ...
	 * @author ...
	 */
	 
	public class LevelOneGen extends LevelGen 
	{
		[Embed(source = '../resources/img/FireBall.png')]private static var fireball:Class;
		
		//{ Constructors/Initialization
		
		public function LevelOneGen(initialElevation : int, width : int, startingDifficulty:int, tileset : Class) {
			super(initialElevation, width, startingDifficulty, tileset)
			TestGenFunctions();
			midBuffer = 4;
			//difficultyIncrease = 6;
		}
		
			override public function InitializeGenFunctions() : void 
		{

			genFunctionHelper.addFunction("Slope", GenSlope, 1, 100, "yUp", 2);
			genFunctionHelper.addFunction("Hurtle", GenHurtle, 1, 5, "hurtle");

			genFunctionHelper.addFunction("SmallGap", GenSmallGap, 1, 4, "gap");
			genFunctionHelper.addFunction("SmallGap", GenSmallGap, 2, 4, "gap");
			genFunctionHelper.addFunction("OptionalSlide", GenOptionalSlide, 1, 3, "slide");
			genFunctionHelper.addFunction("Drop", GenDrop, 1, 100, "yDown");
			genFunctionHelper.addFunction("EnemyWalker", GenEnemyWalker, 1, 100, "enemy");

			genFunctionHelper.addFunction("AdvancedHurtle", GenAdvancedHurtle, 2, 6, "hurtle");

			
			genFunctionHelper.addFunction("Slide", GenSlide, 2, 9, "slide");
			genFunctionHelper.addFunction("Drop", GenDrop, 2, 100, "yDown");
			genFunctionHelper.addFunction("Steps", GenSteps, 2, 100, "yUp");
			genFunctionHelper.addFunction("EnemyWalker", GenEnemyWalker, 2, 4, "enemy");
			genFunctionHelper.addFunction("Gap", GenGap, 6, 7, "gap");
			genFunctionHelper.addFunction("Gap", GenGap, 6, 8, "gap");

			genFunctionHelper.addFunction("SpringboardEasy", GenSpringboardEasy, 3, 8, "yUp");
			genFunctionHelper.addFunction("SpringboardGap", GenSpringboardGap, 7, 100, "gap");

			genFunctionHelper.addFunction("Slide", GenSlide, 3, 10, "slide");
			genFunctionHelper.addFunction("OnePlatformGap", GenOnePlatformGap , 3, 5, "gap");
			
			genFunctionHelper.addFunction("GapHurtle", GenGapHurtle , 6, 100, "gap");
			genFunctionHelper.addFunction("TripleEnemy", GenTripleEnemy, 6, 100, "enemy");
			genFunctionHelper.addFunction("EnemyJumper", GenEnemyJumper, 6, 100, "enemy");
			genFunctionHelper.addFunction("EnemyJumper", GenEnemyJumper, 6, 100, "enemy");
			genFunctionHelper.addFunction("BalloonGap", BalloonGap, 6, 100, "gap");
			genFunctionHelper.addFunction("BalloonGap", BalloonGap, 6, 100, "gap");

			genFunctionHelper.addFunction("OneCrumblePlatformGap", GenOneCrumblePlatformGap , 6, 100, "gap");
			genFunctionHelper.addFunction("Fireball", GenFireball, 8, 10, "hazard");
			genFunctionHelper.addFunction("Fireball", GenFireball, 8, 9, "hazard");

			genFunctionHelper.addFunction("FlameStick", GenFlameStick, 9, 100, "hazard");
			genFunctionHelper.addFunction("SlideJump", GenSlideJump, 7, 100, "slide");
			genFunctionHelper.addFunction("LargeGap", GenLargeGap, 11, 100, "gap");
			genFunctionHelper.addFunction("LargeGap", GenLargeGap, 13, 100, "gap");
			genFunctionHelper.addFunction("LargeGap", GenLargeGap, 15, 100, "gap");
			genFunctionHelper.addFunction("FireballBarrage", GenFireballBarrage, 11, 100, "hazard");
			genFunctionHelper.addFunction("FireballBarrage", GenFireballBarrage, 11, 100, "hazard");


			//genFunctions.push(new GenFunction(GenMultiLevel, 3, 10, "multiLevel"));

		}
		
		//function to reset the function list and load a set of genfunctions for testing
		public function TestGenFunctions() : void {
			//genFunctions = new Array();
		
			//genFunctions.push(new GenFunction(GenFlat, 1, 100, "flat"));
			//genFunctions.push(new GenFunction(GenOneWayPlatformSteps, 1, 100, "yUp"));
			//genFunctions.push(new GenFunction(BaloonGap, 1, 100, "balloon"));

		}
		//} end Constructors/Initialization
		
		//{ Level Generation Functions
		
		
		//{ Flat obstacles
		//all obstacles that don't involve a gap and don't mess with elevation
		
		public function FlatLevel() : void {
			GenFlat(50);
			GenEnemyWalker();
			GenFlat(currentChunk.widthInTiles - 65);
		}
		
		public function GenEnemyJumper() : void {
			var startX : int = currentX;
			GenFlat(5);
			var jumper : EnemyJumper = new EnemyJumper();
			currentChunk.AddEntityAtTileCoords(jumper, startX + 2, currentY - 1); 
		}
		
		public function GenEnemyWalker() : void {
			var en : EnemyWalker = new EnemyWalker();

			GenFlat(2);

			currentChunk.AddEntityAtTileCoords(en, currentX-1, currentY - 2);

		}

		public function GenTripleEnemy() : void {
			GenEnemyWalker();
			GenEnemyWalker();
			GenEnemyWalker();
			
		}
		
		public function GenOptionalSlide() : void {
			var startX : int = currentX;
			GenFlat(4);
			currentChunk.FillSolid(startX + 1, currentY - 3, 2, 2, 8);
			addCollectible(startX + 1, currentY -  1);
			addCollectible(startX + 2, currentY -  1);
		}

		public function GenSlide() : void {
			var startX : int = currentX;
			GenFlat(3);
			currentChunk.FillSolid(startX + 1, currentY - 6, 1, 5, 8);
		}
		
		public function GenHurtle(h : int = -1) : void {
			var height : int;
			if (h == -1) {
				height = CommonFunctions.getRandom(2, 3);
			}
			else {
				height = h;
			}

			var startX : int = currentX;

			GenFlat(4);

			currentChunk.FillSolid(startX + 1, currentY - height, 2, height, 8);


			addCollectible(startX + 1, currentY - height - 1);
			addCollectible(startX + 2, currentY - height - 1);

		}

		public function GenAdvancedHurtle() : void {
			GenHurtle(2);
			GenFlat(2);
			GenHurtle(4);
		}
		
		public function GenFireball(h : int = 2, buffer : int = 10, seriesNum : int = 0) : void {
			GenFlat(3);
			var dp : DeathProjectile = new DeathProjectile(fireball, 16, 16, -150, 0, 3);
			dp.activationDistance -= CommonConstants.TILEWIDTH * seriesNum * 3;
			currentChunk.AddEntityAtTileCoords(dp, currentX + buffer, currentY - h);
		}

		public function GenFireballBarrage() : void {
			var num : int = CommonFunctions.getRandom(2, 5);
			for (var i : int = 0; i < num; i++) {
				GenFireball(CommonFunctions.getRandom(1, 4), i*7, i);
			}
			
		}
		
		public function GenFlameStick() : void {
			GenFlat(3);
			var targetX : int = currentX - 2;
			var targetY : int = currentY;
			currentChunk.mainTiles.setTile(targetX, targetY, 9);
			
			var length : int = 4;
			for (var i:int = 0; i < length; i++) {
				var fireball : RotatingFlame = new RotatingFlame(targetX * CommonConstants.TILEWIDTH, targetY * CommonConstants.TILEHEIGHT, (i + 1) * 16);
				currentChunk.AddEntityAtTileCoords(fireball, targetX + 1 + i, targetY);
			}
			
		}
		
		
		//} end Flat obstacles
		
		//{ Gap obstacles
		//obstacles that have a gap
		
		public function BalloonGap() : void {
			var startX : int = currentX;
			GenGap(15);
			
			AddSimpleMovingPlatform(startX + 4, currentY, currentX - 4, currentY);
			//addCollectible(startX + 2, currentY - 8);
			//AddCoinArch(startX + 4, currentY - 9, 4);
		}
		
		//basic gap, between 3 and 5 width
		public function GenSmallGap() : void {

			var width : int = CommonFunctions.getRandom(3, 5);

			super.GenGap(width);
		}

		//medium gap with a 3-width platform in the middle
		public function GenOnePlatformGap(crumble:Boolean = false) : void {
			var startX : int = currentX;

			var jumpWidth : int = CommonFunctions.getRandom(4, 6);
			var platformWidth : int = 3;
			var platformHeight : int = CommonFunctions.getRandom( -2, 2);

			GenGap(jumpWidth * 2 + platformWidth);
			
			AddPlatform(startX + jumpWidth, currentY + platformHeight, 3, crumble);
			

		}
		
		//Same as GenOnePlatformGap, but with crumble-tiles instead
		public function GenOneCrumblePlatformGap() : void {
			GenOnePlatformGap(true);
		}
		
		//A gap covered by crumble tiles
		public function GenCrumbleGap() : void {
			var startX : int = currentX;
			GenGap(5);
			
			AddPlatform(startX, currentY, 5, true);
		}

		//large gap with randomized platforms and height differences
		public function GenLargeGap() : void {
			var remainingLevel : int = currentChunk.widthInTiles - currentX;
			var numPlatforms : int = CommonFunctions.getRandom(1, 3);

			var possibleJumps : int = remainingLevel / 20;  //20 is the maximum "width" of one jump (10 length to platform, 10 length to end)
			if (numPlatforms > possibleJumps) numPlatforms = possibleJumps;

			var jumpWidths : Array = new Array();
			var jumpHeights : Array = new Array();

			var totalWidth : int = 0;

			for (var i:int = 0; i < numPlatforms; i++) {
				var maxYGain : int = 3;
				var minYGain : int = -3;

				if (currentY > CommonConstants.LEVELHEIGHT - 10) maxYGain = 0;
				if (currentY < 10) minYGain = 0;

				var jHeight : int = CommonFunctions.getRandom(minYGain, maxYGain);
				var maxDistance : int = CalcMaxJumpDistance(jHeight) - 1;

				if (maxDistance < 5) maxDistance = 5;

				var jWidth : int = CommonFunctions.getRandom(5, maxDistance);

				jumpWidths.push(jWidth);
				jumpHeights.push(jHeight);
				totalWidth += jWidth + 2;
			}

			totalWidth += CommonFunctions.getRandom(5, 8);


			var startX : int = currentX + 1;
			GenGap(totalWidth);

			for (var i:int = 0; i < numPlatforms; i++) {
				startX += jumpWidths[i];
				currentY += jumpHeights[i];
				
				AddPlatform(startX, currentY, 2);

				startX += 2;

			}

		}
		
		//slide, followed by a gap
		public function GenSlideJump() : void {
			GenSlide();
			GenFlat(1);
			GenGap(6);
			currentY += CommonFunctions.getRandom( -2, 3);

		}
		
		//set of short jumps with gaps between them
		public function GenGapHurtle() : void {
			var numJumps : int = CommonFunctions.getRandom(3, 5);
			for (var i:int = 0; i < numJumps; i++) {
				var gapWidth : int = CommonFunctions.getRandom(2, 4);
				var gapHeight : int = FlxG.getRandom([-2, 2, -3]) as int;

				GenGap(gapWidth);
				currentY += gapHeight;
				GenFlat(3);
			}

		}
		
		//large gap that requires springboard usage to get over
		public function GenSpringboardGap() : void {
			var gapWidth : int = CommonFunctions.getRandom(10, 15);
			if (gapWidth + 2 + currentX >= this.currentChunk.widthInTiles) return;
			GenSpringboard();
			GenGap(gapWidth);
		}
		
		//} end Gap obstacles
		
		//{ Elevation change obstacles
		//functions that will mess with the elevation
		public function GenSlope() : void {
			if (this.currentY < 5) return;
			var numSteps : int = CommonFunctions.getRandom(1, 3);

			for (var i:int = 0; i < numSteps; i++) {
				currentY--;
				GenFlat(2);
			}
		}

		public function GenSteps() : void{
			if (this.currentY < 10) return;
			var numSteps : int = CommonFunctions.getRandom(1, 3);

			for (var i:int = 0; i < numSteps; i++) {
				currentY-= 2;
				GenFlat(3);
			}
		}
		
		public function GenOneWayPlatformSteps() : void {
			if (this.currentY < 8) return;
			var numSteps : int = CommonFunctions.getRandom(1, 3);
			var height : int = numSteps * 2;
			var width : int = 0;
			var startX : int = currentX;
			
			for (var i:int = 1; i <= numSteps; i++) {
				var x : int = CommonFunctions.getRandom(0, 2);
				var y : int = currentY - i * 2;
				var w : int = CommonFunctions.getRandom(2, 4);
				width += w;
				currentChunk.FillSolidRect(currentChunk.mainTiles, startX + x, y, startX + x + w, y, Chunk.oneWayPlatform);
				currentChunk.FillSolidRect(currentChunk.bgTiles, startX + x, y, startX + x + w, currentY-1, Chunk.middle);
				
				startX += w + x;
			}
			
			//currentChunk.FillSolidRect(currentChunk.bgTiles, currentX, currentY, currentX + width, currentY - height, Chunk.middle);
				
			GenFlat(width);
			
			currentY -= height;
		}
		
		public function GenDrop() : void {
			if (this.currentY > CommonConstants.LEVELHEIGHT - 12) return;
			var dropHeight : int = CommonFunctions.getRandom(2, 6);
			currentY += dropHeight;

		}
		
		public function GenSpringboardEasy() : void {
			var cliffHeight : int = CommonFunctions.getRandom(5, 7);
			if (currentY - cliffHeight < 10) return;

			GenSpringboard();
			GenFlat(6);
			currentY -= cliffHeight;
		}
		
		
		//} end Election change obstacles

		//{ Helper functions
		public function GenSpringboard() : void {
			GenFlat(2);
			var springboard : Springboard = new Springboard();
			currentChunk.AddEntityAtTileCoords(springboard, currentX - 2, currentY - 1);
		}
		
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

		//} end Helper functions



		//} region Level Generation Functions

	}

}