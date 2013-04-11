package  
{
	import org.flixel.*;
	/**
	 * ...
	 * @author ...
	 */
	public class LevelOneChunkGen extends ChunkGen 
	{
		[Embed(source = '../resources/img/alientileset.png')]private static var alienTileset:Class;
		
		private var obstacleFunctions:Array ;	
		private var lastDifficulty : int = 0;
		
		public function LevelOneChunkGen(startingX:int = 0, startingHeight:int = -1) 
		{
			this.tileset = alienTileset;
			super(startingX, startingHeight);
			obstacleFunctions = new Array();
		}
		
		override protected function GetValidFunctions():Array 
		{
			var functions : Array = new Array();
			
			
			var difficulty : int = GetDifficulty();
			
			functions.push(Flat);
			if(difficulty > 0){
				functions.push(Gap);
				functions.push(ElevationChange);
				functions.push(super.GenMultiLevel);
			}
			

			return functions;
		}
		
		//Each of the base functions will 
		//{ region BaseFunctions
		
		private function Flat() : Chunk {
			var diff:int = GetDifficulty();
			
			if (diff != lastDifficulty){
				UpdateFlatObstacles(diff);
				lastDifficulty = diff;
			}
			var returned : Chunk = super.GenFlat();
			
			
			//number of obstacles is at max 4, but otherwise diff/4.  So at 8 difficulty, numObstacles should be 2, but at 24 difficulty, numObstacles will only be 4
			var maxObstacles : int = (diff/4 > 4 ? 4 : diff / 4)
			var numObstacles : int = CommonFunctions.getRandom(0, maxObstacles);
			
			//add obstacles, the obstacle functions will do nothing if there is no room for the obstacles.
			while (numObstacles > 0 && obstacleFunctions.length > 0) {
				var obstacleFunction : Function = FlxU.getRandom(obstacleFunctions) as Function;
				obstacleFunction(returned);
				numObstacles --;
			}
			
			return returned;
		}
		
		private function Gap() : Chunk{
			return super.GenGap();
		}
		
		private function ElevationChange() : Chunk{
			return super.GenElevationChange();
		}
		
		private function GapElevationChange() : Chunk{
			return super.GenElevationChange();
		}
		
		//} region BaseFunctions
		
		//return which obstacle functions are valid for difficulty
		private function UpdateFlatObstacles(difficulty:int) : void {
			
			switch(difficulty) {
				case 15:
					//returned.push(GenSpinningFlame);
				case 12:
					//returned.push(GenProjectileShooter);
				case 9:
					//returned.push(GenSlideWall);
					//returned.push(GenJumpingEnemy);
				case 7:
					//returned.push(GenDestructableWall);
					//returned.push(GenAdvancedHurtles);
				
				case 4:
					obstacleFunctions.push(GenBasicEnemy);
					break;
				
				case 1:
					obstacleFunctions.push(GenBasicHurtles);
					obstacleFunctions.push(GenPyramid);
					break;
				
				//Advanced hurtles
				//Pyramids
				//Basic enemy
				//Destructable blocks
				//1-high slide section
				//Jumping enemy
				//Projectile shooters
				//Spinning flames
			}
			
		}
		
		//{ region Flat generation functions
		
		//generates a 2-high block at the chunk's current obstacleX
		private function GenBasicHurtles(chunk : Chunk) : void{
			if (chunk.obstacleX < chunk.width - 3) {
				chunk.FillSolid(chunk.obstacleX, currentElevation - 1, 2, 2); 
				chunk.obstacleX += 7;
			}
		}
		
		private function GenAdvancedHurtles(chunk : Chunk) : void{
			
		}
		
		//generates a blocky pyramid of random width
		private function GenPyramid(chunk : Chunk) : void{
			var baseWidth : int = FlxU.getRandom([1, 3, 5, 7]) as int;
			while (baseWidth > chunk.width - chunk.obstacleX) {
				baseWidth -= 2;
			}
			
			if (baseWidth < 0) return;
			
			for (var h:int = 0; h < (baseWidth + 1) / 2; h++) {
				for (var x:int = chunk.obstacleX + h; x < chunk.obstacleX + baseWidth - h; x++ ) {
					chunk.mainTiles.setTile(x, currentElevation - h - 1, 17);
				}
			}
			
			chunk.obstacleX += baseWidth + 1;
		}
		
		//Adds a basic enemy to the chunk
		private function GenBasicEnemy(chunk : Chunk) : void{
			var enemy : Enemy = new Enemy(chunk.obstacleX, currentElevation - 32);
			chunk.AddEntityAtTileCoords(enemy, chunk.obstacleX, currentElevation-2);
			chunk.obstacleX += 2;
		}
		
		private function GenDestructableWall(chunk : Chunk) : void{
			
		}
		
		private function GenSlideWall(chunk : Chunk) : void{
			
		}
		
		private function GenJumpingEnemy(chunk : Chunk) : void{
			
		}
		
		private function GenProjectileShooter(chunk : Chunk) : void{
			
		}
		
		private function GenSpinningFlame(chunk : Chunk) : void{
			
		}
		
		
		
		//} region Flat generation functions
		
	}

}