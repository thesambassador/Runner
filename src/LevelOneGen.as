package 
{
	
	/**
	 * ...
	 * @author ...
	 */
	public class LevelOneGen extends LevelGen 
	{
		public function LevelOneGen(initialElevation : int, width : int, startingDifficulty:int, tileset : Class) {
			super(initialElevation, width, startingDifficulty, tileset)
			
		}
		
		override public function InitializeGenFunctions() : void 
		{

			genFunctions.push(new GenFunction(GenSlope, 1, 100, "changeY"));
			genFunctions.push(new GenFunction(GenHurtle, 1, 100, "hurtle"));
			
			genFunctions.push(new GenFunction(GenGap, 1, 4, "gap"));
			genFunctions.push(new GenFunction(GenOptionalSlide, 1, 3, "slide"));
			genFunctions.push(new GenFunction(GenDrop, 1, 100, "changeY"));
			genFunctions.push(new GenFunction(GenFlatEnemy, 1, 100, "enemy"));
			
			genFunctions.push(new GenFunction(GenAdvancedHurtle, 2, 100, "hurtle"));
			
			genFunctions.push(new GenFunction(GenSlide, 2, 100, "slide"));
			genFunctions.push(new GenFunction(GenDrop, 2, 100, "changeY"));
			genFunctions.push(new GenFunction(GenSteps, 2, 100, "changeY"));
			genFunctions.push(new GenFunction(GenFlatEnemy, 2, 4, "enemy"));
			
			genFunctions.push(new GenFunction(GenGap, 2, 5, "gap"));
			genFunctions.push(new GenFunction(GenGap, 2, 6, "gap"));
			genFunctions.push(new GenFunction(GenGap, 3, 100, "gap"));
			genFunctions.push(new GenFunction(GenSlide, 3, 100, "slide"));
			genFunctions.push(new GenFunction(GenTripleEnemy, 3, 100, "enemy"));
			
			genFunctions.push(new GenFunction(GenAdvancedHurtle, 4, 100, "hurtle"));
			genFunctions.push(new GenFunction(GenLargeGap, 4, 100, "gap"));
			genFunctions.push(new GenFunction(GenLargeGap, 5, 100, "gap"));
			genFunctions.push(new GenFunction(GenLargeGap, 6, 100, "gap"));
			

			//genFunctions.push(new GenFunction(GenMultiLevel, 3, 10, "multiLevel"));

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
		
		//large gap with platforms
		public function GenLargeGap() {
			var numPlatforms : int = CommonFunctions.getRandom(1, 3);
			
			var jumpWidths : Array = new Array();
			var jumpHeights : Array = new Array();
			
			var totalWidth : int = 0;
			
			for (var i:int = 0; i < numPlatforms; i++) {
				var jHeight : int = CommonFunctions.getRandom( -3, 3);
				var maxDistance : int = CalcMaxJumpDistance(jHeight);
				
				if (maxDistance < 5) maxDistance = 5;
				
				var jWidth : int = CommonFunctions.getRandom(5, maxDistance);
				if (maxDistance < 5) {
					var x = 5;
				}
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
		
		public function GenFlatEnemy() : void {
			var en : Enemy = new Enemy();
			
			GenFlat(1);
			
			currentChunk.AddEntityAtTileCoords(en, currentX-1, currentY - 1);
			
		}
		
		public function GenTripleEnemy() : void {
			GenFlatEnemy();
			GenFlatEnemy();
			GenFlatEnemy();
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
			if (this.currentY > CommonConstants.LEVELHEIGHT - 8) return;
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
		
		public function GenAdvancedHurtle() {
			GenHurtle(2);
			GenFlat(2);
			GenHurtle(4);
		}
		
		//x: x value of first collectible
		//y: elevation to start
		//  **        *
		// *  *  or  * *
		// w=4       w=3
		public function AddCoinArch(sx:int, sy:int, w:int) {
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