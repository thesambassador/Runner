package 
{
	import org.flixel.FlxG;
	/**
	 * ...
	 * @author ...
	 */
	public class LevelOneGen extends LevelGen 
	{
		[Embed(source = '../resources/img/FireBall.png')]private static var fireball:Class;
		public function LevelOneGen(initialElevation : int, width : int, startingDifficulty:int, tileset : Class) {
			super(initialElevation, width, startingDifficulty, tileset)
			//TestGenFunctions();
			midBuffer = 4;
		}

		public function TestGenFunctions() : void {
			genFunctions = new Array();
			genFunctions.push(new GenFunction(GenFlat, 1, 9, "flat"));
			//genFunctions.push(new GenFunction(GenTripleEnemy, 1, 7, "enemy"));
			//genFunctions.push(new GenFunction(GenFireballBarrage, 1, 7, "as"));
			//genFunctions.push(new GenFunction(GenSpringboardEasy, 1, 7, "changeY"));
			//genFunctions.push(new GenFunction(GenSpringboardGap, 1, 7, "gap"));
			genFunctions.push(new GenFunction(GenGapHurtle, 1, 7, "gap"));


		}

		public function FlatLevel() : void {
			GenFlat(50);
			GenEnemyWalker();
			GenFlat(currentChunk.widthInTiles - 65);
		}

		override public function InitializeGenFunctions() : void 
		{

			genFunctions.push(new GenFunction(GenSlope, 1, 100, "changeY"));
			genFunctions.push(new GenFunction(GenSlope, 1, 2, "changeY"));
			genFunctions.push(new GenFunction(GenHurtle, 1, 100, "hurtle"));

			genFunctions.push(new GenFunction(GenGap, 1, 4, "gap", "enemy"));
			genFunctions.push(new GenFunction(GenOptionalSlide, 1, 3, "slide"));
			genFunctions.push(new GenFunction(GenDrop, 1, 100, "changeY"));
			genFunctions.push(new GenFunction(GenEnemyWalker, 1, 100, "enemy"));

			genFunctions.push(new GenFunction(GenAdvancedHurtle, 2, 6, "hurtle"));

			genFunctions.push(new GenFunction(GenEnemyJumper, 5, 100, "enemy"));
			genFunctions.push(new GenFunction(GenSlide, 2, 9, "slide", "enemy"));
			genFunctions.push(new GenFunction(GenDrop, 2, 100, "changeY"));
			genFunctions.push(new GenFunction(GenSteps, 2, 100, "changeY"));
			genFunctions.push(new GenFunction(GenEnemyWalker, 2, 4, "enemy"));
			genFunctions.push(new GenFunction(GenGap, 2, 5, "gap", "enemy"));
			genFunctions.push(new GenFunction(GenGap, 2, 6, "gap", "enemy"));

			genFunctions.push(new GenFunction(GenSpringboardEasy, 3, 8, "gap", "enemy"));
			genFunctions.push(new GenFunction(GenSpringboardGap, 7, 100, "gap", "enemy"));

			genFunctions.push(new GenFunction(GenSlide, 3, 10, "slide", "enemy"));
			genFunctions.push(new GenFunction(GenOnePlatformGap , 3, 9, "gap", "enemy"));
			genFunctions.push(new GenFunction(GenGapHurtle , 6, 100, "gap"));
			genFunctions.push(new GenFunction(GenTripleEnemy, 6, 100, "enemy"));
			genFunctions.push(new GenFunction(GenEnemyJumper, 6, 100, "enemy"));
			genFunctions.push(new GenFunction(GenEnemyJumper, 6, 100, "enemy"));


			genFunctions.push(new GenFunction(GenFireball, 5, 8, "hazard"));
			genFunctions.push(new GenFunction(GenFireball, 5, 8, "hazard"));
			genFunctions.push(new GenFunction(GenOnePlatformGap , 5, 100, "gap", "enemy"));


			genFunctions.push(new GenFunction(GenSlideJump, 5, 100, "slide", "enemy"));
			genFunctions.push(new GenFunction(GenAdvancedHurtle, 4, 7, "hurtle"));
			genFunctions.push(new GenFunction(GenLargeGap, 10, 100, "gap", "enemy"));
			genFunctions.push(new GenFunction(GenLargeGap, 8, 100, "gap", "enemy"));
			genFunctions.push(new GenFunction(GenLargeGap, 9, 100, "gap", "enemy"));
			genFunctions.push(new GenFunction(GenFireballBarrage, 8, 100, "hazard"));
			genFunctions.push(new GenFunction(GenFireballBarrage, 9, 100, "hazard"));


			//genFunctions.push(new GenFunction(GenMultiLevel, 3, 10, "multiLevel"));

		}

		public function GenEnemyJumper() : void {
			var startX : int = currentX;
			GenFlat(5);
			var jumper : EnemyJumper = new EnemyJumper();
			currentChunk.AddEntityAtTileCoords(jumper, startX + 2, currentY - 1); 
		}

		override protected function GenGap(w : int = -1) : void {
			var startX : int = currentX;
			var width : int ;
			if(w == -1)
				width = CommonFunctions.getRandom(4, 8);
			else
				width = w;

			super.GenGap(width);

			//AddCoinArch(startX + 1, currentY - 4, width - 2);

		}

		//medium gap with a 3-width platform in the middle
		public function GenOnePlatformGap() : void {
			var startX : int = currentX;

			var jumpWidth : int = CommonFunctions.getRandom(4, 6);
			var platformWidth : int = 3;
			var platformHeight : int = CommonFunctions.getRandom( -2, 2);

			GenGap(jumpWidth * 2 + platformWidth);

			for (var i:int = 0; i < platformWidth; i++) {
				currentChunk.mainTiles.setTile(startX + jumpWidth + i, currentY + platformHeight, 8);
			}

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

				currentChunk.mainTiles.setTile(startX, currentY, 8)
				currentChunk.mainTiles.setTile(startX + 1, currentY, 8)

				startX += 2;

			}


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

		public function GenDrop() : void {
			if (this.currentY > CommonConstants.LEVELHEIGHT - 12) return;
			var dropHeight : int = CommonFunctions.getRandom(2, 6);
			currentY += dropHeight;

		}

		public function GenEasyMultiLevel() : void {
			var startX : int = currentX;
			GenMultiLevel();


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

		public function GenSlideJump() : void {
			GenSlide();
			GenFlat(1);
			GenGap(6);
			currentY += CommonFunctions.getRandom( -3, 3);

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

		public function GenFireball(h : int = 2) : void {
			GenFlat(6);
			var dp : DeathProjectile = new DeathProjectile(fireball, 16, 16, -150, 0, 3);
			currentChunk.AddEntityAtTileCoords(dp, currentX + 10, currentY - h);
		}

		public function GenFireballBarrage() {
			var num : int = CommonFunctions.getRandom(2, 5);
			for (var i : int = 0; i < num; i++) {
				GenFireball(CommonFunctions.getRandom(1, 4));
			}
		}

		public function GenSpringboard() : void {
			GenFlat(2);
			var springboard : Springboard = new Springboard();
			currentChunk.AddEntityAtTileCoords(springboard, currentX - 2, currentY - 1);
		}

		public function GenSpringboardEasy() : void {
			var cliffHeight : int = CommonFunctions.getRandom(6, 9);
			if (currentY - cliffHeight < 10) return;

			GenSpringboard();
			GenFlat(6);
			currentY -= cliffHeight;
		}

		public function GenSpringboardGap() : void {
			var gapWidth : int = CommonFunctions.getRandom(10, 15);
			if (gapWidth + 2 + currentX >= this.currentChunk.widthInTiles) return;
			GenSpringboard();
			GenGap(gapWidth);
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




	}

}