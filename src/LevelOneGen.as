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

			genFunctions.push(new GenFunction(GenSlope, 0, 10, "changeY"));
			genFunctions.push(new GenFunction(GenGap, 0, 10, "gap"));
			genFunctions.push(new GenFunction(GenGap, 0, 10, "gap"));
			genFunctions.push(new GenFunction(GenGap, 0, 10, "gap"));
			genFunctions.push(new GenFunction(GenGap, 0, 10, "gap"));
			genFunctions.push(new GenFunction(GenSteps, 0, 10, "changeY"));
			genFunctions.push(new GenFunction(GenDrop, 0, 10, "changeY"));
			genFunctions.push(new GenFunction(GenDrop, 0, 10, "changeY"));
			//genFunctions.push(new GenFunction(GenMultiLevel, 0, 10, "multiLevel"));
			genFunctions.push(new GenFunction(GenSlide, 0, 10, "slide"));
			genFunctions.push(new GenFunction(GenHurtle, 0, 10, "hurtle"));
	
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
		
		public function GenSlide() : void {
			var startX : int = currentX;
			GenFlat(3);
			currentChunk.FillSolid(startX + 1, currentY - 6, 1, 5, 8);
		}
		
		public function GenHurtle() : void {
			var startX : int = currentX;
			GenFlat(4);
			
			var height : int = CommonFunctions.getRandom(2, 3);
			
			currentChunk.FillSolid(startX + 1, currentY - height, 2, height, 8);
		}
		
		
	}
	
}