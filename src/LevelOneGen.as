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
			//TestGenFunctions();
			midBuffer = 4;
			//difficultyIncrease = 6;
		}
		
		//function to reset the function list and load a set of genfunctions for testing
		public function TestGenFunctions() :  void {
			genFunctionHelper = new GenFunctionHelper;
			
			//genFunctionHelper.addFunction("steps", GenRandomEasyPlatform, 1, 100, "flat", 1);
			genFunctionHelper.addFunction("Flat2", GenFlat, 1, 100, "flat3", 1);
			genFunctionHelper.addFunction("Flat", GenLowHeightGap, 1, 100, "elevationChange", 1);
			//genFunctionHelper.addFunction("Flat", GenTinyPlatformSlideGap, 2, 3, "elevationChange", 1);
			//genFunctionHelper.addFunction("Flat", GenTinyPlatformSlideGapCrumble, 3, 100, "elevationChange", 1);
			
			//genFunctionHelper.addFunction("Flat", SinglePlatformElevationChange, 1, 100, "elevationChanges", 1);


		}
		
		//populates the gen function helper with the genfunctions that we'll use in this level
		override public function InitializeGenFunctions() : void 
		{
			//game starts at a difficulty of 1, increases 2 per level, does increase halfway through the level (even numbered difficulties will show up mid-level)
			
			//most basic level gen stuff, NO danger to player, eventually phased out once difficulty starts getting high
			genFunctionHelper.addFunction("Steps", GenSteps, 1, 11, "elevationChange", 1);
			genFunctionHelper.addFunction("Slope", GenSlope, 1, 11, "elevationChange", 1);
			genFunctionHelper.addFunction("Drop", GenDrop, 1, 11, "elevationChange", 1);
			genFunctionHelper.addFunction("Pyramid", GenPyramid, 1, 7, "hurtle", 1);
			//genFunctionHelper.addFunction("TrianglePlatforms", GenTrianglePlatforms, 1, 9, "scenery", 1);
			genFunctionHelper.addFunction("Hurtle", GenHurtle, 1, 11, "hurtle", 1);
			genFunctionHelper.addFunction("EasyPlatform", GenRandomEasyPlatform, 1, 11, "hurtle", 2);
			
			//these two are sort of "teacher features", just a preview of upcoming hazards, stop them from showing up after the first level
			genFunctionHelper.addFunction("OptionalSlide", GenOptionalSlide, 1, 3, "slide", 1);
			genFunctionHelper.addFunction("CrumbleGap", GenCrumbleGap, 1, 3, "scenery", 1);
			genFunctionHelper.addFunction("SpringboardEasy", GenSpringboardEasy, 3, 13, "elevationChange", 1);
		
			
			//SMALL danger to player, weight these a bit more than the others so we get more of them, but these also are phased out initially
			genFunctionHelper.addFunction("SmallGap", GenSmallGap, 1, 9, "gap", 3);
			genFunctionHelper.addFunction("EnemyWalker", GenEnemyWalker, 1, 11, "enemy", 2);
			genFunctionHelper.addFunction("EnemyWalker", GenTripleEnemy, 3, 13, "enemy", 1);
			genFunctionHelper.addFunction("OnePlatformGap", GenOnePlatformGap, 2, 5, "gap", 1);
			
			//These functions replace the "Helper" ones once those phase out
			genFunctionHelper.addFunction("OneCrumblePlatformGap", GenOneCrumblePlatformGap, 5, 13, "gap", 1);
			genFunctionHelper.addFunction("Slide", GenSlide, 3, 11, "slide", 1);
			genFunctionHelper.addFunction("AdvancedHurtle", GenAdvancedHurtle, 4, 11, "hurtle", 1);
			
			//mid range difficulty stuff
			genFunctionHelper.addFunction("OnePlatformElevation", GenSinglePlatformElevationChange, 9, 13, "elevationChange", 2);
			genFunctionHelper.addFunction("FlameStick", GenFlameStick, 9, 12, "hazard", 1);
			genFunctionHelper.addFunction("Fireball", GenFireball, 9, 30, "hazard", 2);
			genFunctionHelper.addFunction("LowHeightGap", GenLowHeightGap, 7, 17, "hazard", 1);
			genFunctionHelper.addFunction("SlideGap", GenSlideJump, 9, 15, "hazard", 1);
			genFunctionHelper.addFunction("EnemyJumper", GenEnemyJumper, 7, 15, "enemy", 1);
			genFunctionHelper.addFunction("GapHurtle", GenGapHurtle, 9, 15, "gap", 1);
			genFunctionHelper.addFunction("PlatformSlideGap", GenPlatformSlideGap, 13, 26, "gap", 1);
			
			
			genFunctionHelper.addFunction("SmallerOnePlatformElevation", GenSmallerPlatformElevationChange, 12, 16, "elevationChange", 2);
			genFunctionHelper.addFunction("CrumbleOnePlatformElevation", GenCrumblePlatformElevationChange, 15, 1000, "elevationChange", 2);

			
			//more difficult stuff
			genFunctionHelper.addFunction("SpringboardGap", GenSpringboardGap, 11, 19, "gap", 1);
			genFunctionHelper.addFunction("FlamestickGap", GenFlameStickPlatform, 15, 30, "gap", 1);
			genFunctionHelper.addFunction("FlamePyramid", GenFirePyramid, 20, 1000, "hazard", 1);
			genFunctionHelper.addFunction("LargeGap", GenLargeGap, 13, 30, "gap", 1);
			genFunctionHelper.addFunction("DeathTunnel", GenDeathTunnel, 14, 30, "hazard", 1);
			
			genFunctionHelper.addFunction("TinyPlatformSlideGap", GenTinyPlatformSlideGap, 26, 34, "gap", 1);
			genFunctionHelper.addFunction("TinyCrumblePlatformSlideGap", GenTinyPlatformSlideGapCrumble, 34, 1000, "gap", 1);
			
			
			genFunctionHelper.addFunction("FireballBarage", GenFireballBarrage, 30, 1000, "hazard", 1);
			genFunctionHelper.addFunction("LargeGap", GenLargeGap, 17, 30, "gap", 1);
			genFunctionHelper.addFunction("LargeGap", GenCrumbleLargeGap, 21, 1000, "gap2", 3);
			

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
		
		//generates 3 platforms, 2 low and 1 high, with a random platform being a 'crumble' platform and a random platform having coins.
		public function GenTrianglePlatforms() : void {
			var startX : int = currentX;
			
			var height : int = 3;
			var spacing : int = CommonFunctions.getRandom(1, 2);
			var platformWidth : int = CommonFunctions.getRandom(2, 4);
			var sidesCrumble : int = CommonFunctions.getRandom(0, 2);
			
			var coinPlatform : int = CommonFunctions.getRandom(1, 2);
			
			GenFlat(platformWidth * 3 + spacing * 2);
			
			AddPlatform(startX, currentY - height, platformWidth, sidesCrumble == 2);
			AddPlatform(startX + platformWidth + spacing, currentY - 2 * height, platformWidth, sidesCrumble == 1, coinPlatform == 1);
			AddPlatform(startX + platformWidth * 2 + 2 * spacing, currentY - height, platformWidth, sidesCrumble == 2, coinPlatform == 2);
			
		}
		
		public function GenEnemyJumper() : void {
			var startX : int = currentX;
			GenFlat(5);
			var jumper : EnemyJumper = new EnemyJumper();
			currentChunk.AddEntityAtTileCoords(jumper, startX + 2, currentY - 1); 
		}
		
		public function GenEnemyWalker(coinChange : Number = 0) : void {
			if (lastCategory == "slide") return;
			
			var en : EnemyWalker = new EnemyWalker();

			GenFlat(2);

			if (FlxG.random() < coinChange) {
				AddCoinArch(currentX + 1, currentY - 7, 4);
			}
			
			currentChunk.AddEntityAtTileCoords(en, currentX-1, currentY - 2);

		}

		public function GenTripleEnemy() : void {
			GenEnemyWalker();
			GenEnemyWalker(.5);
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
			currentChunk.FillSolid(startX + 1, currentY - 5, 1, 4, 8);
			
			var prevType : String = checkPreviousType();
			if (prevType == "Drop" || prevType == "EnemyWalker") {
				AddCoinRect(startX + 1, currentY - 7, startX + 1, currentY - 6); 
			}
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

		}

		public function GenAdvancedHurtle() : void {
			if (difficulty <= 4) {
				if(currentChunk.mainTiles.getTile(currentX-1, currentY-4) == 0){
					addCollectible(currentX - 1, currentY -4);
					addCollectible(currentX, currentY -5);
				}
			}
			
			GenFlat(4);
			GenHurtle(2);
			GenFlat(2);
			GenHurtle(4);
		}
		
		public function GenDeathHurtle() : void {
			var height : int = 1;
			GenHurtle(height);
			currentChunk.FillSolidRect(currentChunk.mainTiles, currentX-3, currentY - height - 1, currentX-2, currentY - height - 1, 16);
		}
		
		public function GenPyramid(height:int = -1, bonusSection : Boolean = true) : void {
			var startX : int = currentX;
			if(height == -1) height = CommonFunctions.getRandom(2, 4);
			var width : int = (height-1) * 2 + 1
			
			GenFlat(width);
			
			for (var i:int = 0;  i < height; i++) {
				AddPlatform(startX + i, currentY - 1 - i, width - (2 * i));
			}
			
			if (FlxG.random() > .6 && bonusSection) {
				var platHeight : int = currentY - height - 3;
				AddPlatform(currentX + 3, platHeight, 1, false);
				AddCoinRect(currentX + 3, platHeight - 1, currentX + 3, platHeight - 2);
				
				platHeight -= 2;
				AddPlatform(currentX + 12, platHeight, 1, false);
				AddCoinRect(currentX + 12, platHeight - 1, currentX + 12, platHeight - 2);
			}
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
		
		public function GenFlameStick(length : int = 4) : void {
			GenFlat(4);
			var targetX : int = currentX - 2;
			var targetY : int = currentY;
			currentChunk.mainTiles.setTile(targetX, targetY, 9);

			for (var i:int = 0; i < length; i++) {
				var fireball : RotatingFlame = new RotatingFlame(targetX * CommonConstants.TILEWIDTH, targetY * CommonConstants.TILEHEIGHT, (i + 1) * 16);
				currentChunk.AddEntityAtTileCoords(fireball, targetX + 1 + i, targetY);
			}
			
		}
		
		public function AddFlameStick(x:int, y:int, length:int, speed:int = 180) : void {
			for (var i:int = 0; i < length; i++) {
				var fireball : RotatingFlame = new RotatingFlame(x * CommonConstants.TILEWIDTH, y * CommonConstants.TILEHEIGHT, (i + 1) * 16, speed);

				currentChunk.AddEntityAtTileCoords(fireball, x + 1 + i, y);
			}
		}
		
		public function GenDeathTunnel() : void {
			if (currentX + 19 > currentChunk.widthInTiles - 10) return;
			var startX : int = currentX;
			GenFlat(20);
			
			currentChunk.mainTiles.setTile(startX, currentY - 1, 8);
			currentChunk.mainTiles.setTile(startX + 1, currentY - 1, 8);
			currentChunk.mainTiles.setTile(startX + 1, currentY - 2, 8);
			currentChunk.FillSolidRect(currentChunk.mainTiles, startX + 2, currentY - 3, startX + 17, currentY - 1, 8);
			currentChunk.FillSolidRect(currentChunk.mainTiles, startX + 2, currentY - 8, startX + 17, currentY - 30, 8);
			
			currentChunk.mainTiles.setTile(startX + 18, currentY - 1, 8);
			currentChunk.mainTiles.setTile(startX + 18, currentY - 2, 8);
			currentChunk.mainTiles.setTile(startX + 19, currentY - 1, 8);
			
			if(FlxG.random() <= .5){
				AddFlameStick(startX + 5, currentY - 3, 3);
				//AddFlameStick(startX + 9, currentY - 8, 3);
				AddFlameStick(startX + 14, currentY - 3, 3);
			}
			else {
				AddFlameStick(startX + 5, currentY - 8, 3);
				//AddFlameStick(startX + 9, currentY - 3, 3);
				AddFlameStick(startX + 14, currentY - 8, 3);
			}
		}
		
		//hurtle leading to high zone with coins followed by another hurtle
		public function GenEasyPlatform1() : void {
			var topWidth : int = CommonFunctions.getRandom(4, 6);
			
			GenHurtle(3);
			GenFlat(2)
			AddPlatform(currentX, currentY - 6, topWidth, false, true);
			GenFlat(topWidth + 2);
			GenHurtle(3);
		}
		
		
		//2 levels of a solid platform with a springboard first
		public function GenEasyPlatform2() : void {
			var topWidth : int = CommonFunctions.getRandom(6, 8);
			var whichCoin : Boolean = CommonFunctions.getRandom(0, 1) as Boolean;
			
			GenSpringboard();
			GenFlat(4);
			AddPlatform(currentX, currentY - 4, topWidth, false, whichCoin);
			AddPlatform(currentX, currentY - 8, topWidth, false, !whichCoin);
			GenFlat(topWidth);
		}
		
		//2 platforms with a coin arch between
		public function GenEasyPlatform3() : void {
			var gapWidth : int = 8;
			var platformWidth : int = 2;
			
			AddPlatform(currentX, currentY - 3, platformWidth, true, false);
			AddPlatform(currentX + platformWidth + gapWidth, currentY - 3, platformWidth, true, false);
			AddCoinArch(currentX + platformWidth + 2, currentY - 7, 4);
			GenFlat(2 * platformWidth + gapWidth);
		}
		
		public function GenRandomEasyPlatform() : void {
			var choices : Array = [GenTrianglePlatforms, GenEasyPlatform1, GenEasyPlatform2, GenEasyPlatform3];
			var choice : Function = FlxG.getRandom(choices) as Function;
			choice();
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
		
		public function GenLowHeightGap(height : int = 5, width:int = 4) : void {
			var columnHeight : int = 20;
			currentChunk.FillSolid(currentX, currentY - columnHeight - height - 1, width, columnHeight,  Chunk.barrier);
			currentChunk.FillSolid(currentX, currentY - height - 1, width, 1,  Chunk.spikeDown);
			
			var coinWidth = width / 2;
			AddCoinRect(currentX + 1, currentY - 1, currentX + coinWidth, currentY - 1);
			
			GenGap(width);
			
			//currentChunk.FillSolidRect(currentChunk.mainTiles, currentX - 3, currentY - 5, currentX - 2, currentY - 5, Chunk.spikeDown);
		}
		
		public function GenLowerHeightGap() : void {
			GenLowHeightGap(4);
		}
		
		public function GenDoubleLowHeightGap() : void {
			GenLowHeightGap(4, 3);
			GenFlat(2);
			GenLowHeightGap(4, 3);
		}
		

		
		//A gap covered by crumble tiles
		public function GenCrumbleGap(width : int = 3) : void {
			var startX : int = currentX;
			GenGap(width);
			
			AddPlatform(startX, currentY, width, true);
		}
		
		
		//gap with a platform and a low pillar in the middle
		public function GenPlatformSlideGap(platformWidth : int = 5, crumble : Boolean = false) : void {
			var jumpWidth : int = CommonFunctions.getRandom(4, 8);
			var platformHeightDifference : int = CommonFunctions.getRandom( -2, 2);
			AddPlatform(currentX + jumpWidth, currentY + platformHeightDifference, platformWidth, crumble, true);
			FillAbove(currentX + jumpWidth + platformWidth / 2, currentY + platformHeightDifference - 1, currentChunk.mainTiles, Chunk.barrier); 
			
			GenGap(jumpWidth * 2 + platformWidth);
		}
		
		public function GenTinyPlatformSlideGap() : void{
			GenPlatformSlideGap(3);
		}
		
		public function GenTinyPlatformSlideGapCrumble() : void{
			GenPlatformSlideGap(3, true);
		}

		//large gap with randomized platforms and height differences
		public function GenLargeGap(crumble : Boolean = false) : void {
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

			for (i = 0; i < numPlatforms; i++) {
				
				var jumpWidth : int = jumpWidths[i];
				var jumpHeight : int = jumpHeights[i];
				
				if (FlxG.random() >= .5) {
					addCollectible(startX + (jumpWidth / 2) - 1, currentY - 4);
					addCollectible(startX + (jumpWidth / 2), currentY - 4);
					addCollectible(startX + (jumpWidth / 2) + 1, currentY - 4);
				}
				
				startX += jumpWidth;
				currentY += jumpHeight;
				
				while (currentChunk.mainTiles.getTile(startX, currentY) != 0) {
					currentY--;
				}
				
				AddPlatform(startX, currentY, 2, crumble);

				startX += 2;

			}

		}
		
		public function GenCrumbleLargeGap() : void {
			GenLargeGap(true);
		}
		
		//slide, followed by a gap
		public function GenSlideJump() : void {
			if (currentY < 10) return;
			GenSlide();
			GenFlat(1);
			GenGap(6);
			currentY += CommonFunctions.getRandom( -2, 3);

		}
		
		//2 platforms with a spinning fire stick 
		public function GenFlameStickPlatform() : void {
			var gapBuffer : int = 4;
			var botPlatformWidth : int = 5;
			var yOffset : int = CommonFunctions.getRandom(-5, 0);
			var dir = FlxG.getRandom([ -180, 180]);
			AddPlatform(currentX + gapBuffer, currentY + 3 + yOffset, botPlatformWidth, false, dir < 0);
			AddPlatform(currentX + gapBuffer + 1, currentY + yOffset, botPlatformWidth - 2, false, dir > 0);
			AddFlameStick(currentX + gapBuffer + 2, currentY + yOffset, 3, dir);
			GenGap(gapBuffer * 2 + botPlatformWidth);
		}
		
		//pyramid with flaming sticks going around
		public function GenFirePyramid() : void {
			var gapHeight : int = 4;
			var pyramidHeight : int = 3;
			var baseWidth : int = (pyramidHeight - 1) * 2 + 1;
			
			for (var i:int = 0;  i < pyramidHeight; i++) {
				AddPlatform(currentX + i, currentY - gapHeight - (2 * pyramidHeight) + i, baseWidth - (2 * i));
			}
			for (i = 0; i < baseWidth; i++){
				FillAbove(currentX + i, currentY - gapHeight - (2 * pyramidHeight), currentChunk.mainTiles, Chunk.barrier);
			}
			
			AddFlameStick(currentX + baseWidth / 2, currentY - pyramidHeight, 3);
			AddFlameStick(currentX + baseWidth / 2, currentY - pyramidHeight - gapHeight - 1, 3, -180);
				
			AddCoinArch(currentX, currentY - pyramidHeight - 2, 4);
			
			GenPyramid(pyramidHeight, false);
			
			
		}
		
		//set of short jumps with gaps between them
		public function GenGapHurtle() : void {
			if (currentY < 10) return;
			
			var numJumps : int = CommonFunctions.getRandom(2, 4);
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
			var gapWidth : int = CommonFunctions.getRandom(10, 14);
			if (gapWidth + 2 + currentX >= this.currentChunk.widthInTiles) return;
			GenSpringboard();
			
			AddCoinArch(currentX + gapWidth / 2 - 2, currentY - 10, 4);
			
			GenGap(gapWidth);
		}
		
		//} end Gap obstacles
		
		//{ Elevation change obstacles
		//functions that will mess with the elevation
		public function GenSlope() : void {
			
			GenSteps(1, 3);
		}

		public function GenSteps(stepHeight : int = 2, stepWidth : int = 5, steps : int = -1, dir : int = 0) : void{
			var numSteps : int = steps;
			if(numSteps == -1)
				numSteps = CommonFunctions.getRandom(1, 3);
				
			if (dir == 0) {
				var possibleDir : Array = new Array();
				//check to see if we are too close to the ceiling/floor
				
				//ceiling, if far enough away we can still go up higher
				if (currentY > 15) {
					possibleDir.push(-1);
				}
				
				//floor, if far enough away we can still go lower
				if (currentY < CommonConstants.LEVELHEIGHT - 15) {
					possibleDir.push(1);
				}
				//should be impossible: if (possibleDir.length == 0) return; 
				
				dir = FlxG.getRandom(possibleDir) as int;
			}

			for (var i:int = 0; i < numSteps; i++) {
				currentY += stepHeight * dir;
				GenFlat(stepWidth);
			}
			FlxG.log("dir" + dir.toString());
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
		
		public function GenSinglePlatformElevationChange(platformWidth : int = 3, crumble : Boolean = false) {
			var heightChange = CommonFunctions.getRandom(1, 3);
			var dir = GetRandomValidDirection();
			
			heightChange *= 2 * dir; //only want 2, 4, and 6 as options, also get the random direction
			var platformY = heightChange / 2;
			
			currentY += heightChange;
			
			var gapWidth : int = 5;
			
			AddPlatform(currentX + gapWidth, currentY - platformY, platformWidth, crumble); 
			GenGap(gapWidth * 2 + platformWidth);
		}
		
		public function GenSmallerPlatformElevationChange() {
			GenSinglePlatformElevationChange(2, false);
		}
		
		public function GenCrumblePlatformElevationChange() {
			GenSinglePlatformElevationChange(2, true);
		}
		
		public function GenTinyPlatformElevationChange() {
			GenSinglePlatformElevationChange(1, true);
		}
		
		
		public function GenDrop() : void {
			if (this.currentY > CommonConstants.LEVELHEIGHT - 12) return;
			var dropHeight : int = CommonFunctions.getRandom(2, 6);
			currentY += dropHeight;

		}
		
		public function GenSpringboardEasy() : void {
			var cliffHeight : int = CommonFunctions.getRandom(3, 5);
			if (currentY - cliffHeight < 10) return;

			GenSpringboard();
			
			GenFlat(5);
			currentY -= 2;
			GenFlat(1);
			currentY -= cliffHeight - 2;
			
			//if (FlxG.random() < .5) {
				AddCoinArch(currentX - 1, currentY + cliffHeight - 10, 3);
			//}
		}
		
		
		//} end Elevation change obstacles

		//{ Helper functions
		

		//} end Helper functions



		//} region Level Generation Functions

	}

}