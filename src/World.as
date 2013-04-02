package 
{
	import org.flixel.*;

	
	/**
	 * This class will handle all of the actual gameplay stuff.  it will add the player, levels, background, and handle transitions between levels
	 */
	public class World extends FlxGroup
	{
		[Embed(source = '../resources/img/alientileset.png')]private static var alienTileset:Class;
		
		public var levelChunk : Chunk;
		public var currentDifficulty : int = 1;

		public var hud : HUD; //ui group
		public var bgLayer : FlxGroup; //background tiles
		public var midLayer: FlxGroup; //main/collision tiles
		public var fgLayer : FlxGroup; //foreground tiles
		
		public var entities : FlxGroup; //entities, excluding the player
		
		public var player : Player;
		public var background : ScrollingBackground;
		
		public var levelWidth : int = 200;
		
		public var firstChunk : Chunk;
		public var lastChunk : Chunk;
		public var numChunks : int;
		public var endX : int; //end of the level so far, this is the right side of the last generated chunk
		public var startLevelX : int //start of the latest level chunk, the is the LEFT side of the most recent level chunk
		public var endLevelX : int; //end of the actual level so far, this is the right side of the last LEVEL chunk
		public var currentElevation : int; //last elevation, in tile coordinates, so that the next level/chunk will be started at the right level.
		
		public var playerStartX = CommonConstants.TILEWIDTH * 2;
		public var playerStartY = CommonConstants.TILEHEIGHT * .5 * CommonConstants.LEVELHEIGHT;
		
		public function World () {
			//background = new ScrollingBackground();
			//add(background);
			
			
			bgLayer = new FlxGroup();
			midLayer = new FlxGroup();
			fgLayer = new FlxGroup();
			entities = new FlxGroup();
			
			
			add(bgLayer);
			add(midLayer);
			add(entities);
			add(fgLayer);
			
			player = new Player(playerStartX, playerStartY);
			add(player);
			
			hud = new HUD(player);
			add(hud);
			
			
			//set camera and world bounds
			
			var camBoundY : int = CommonConstants.LEVELHEIGHT * CommonConstants.TILEHEIGHT - 20;
			
			FlxG.camera.setBounds(0, 0, 5000000000, camBoundY);
			FlxG.worldBounds = new FlxRect(0, 32, CommonConstants.WINDOWWIDTH + 128, CommonConstants.WINDOWHEIGHT + 128);
			
			CreateInitialPlatform();
			GenLevel();
			
			FlxG.watch(this, "currentDifficulty", "diff");
		}
		
		private function CreateInitialPlatform() : void{
			var startPlatform : Chunk = Chunk.GenFlatChunk(25, 34, alienTileset);

			Chunk.FillUnder(0, 0, startPlatform.mainTiles, 8);
			AddChunk(startPlatform);
		}
		
		private function GenLevel() : void{
			var levGen : LevelGen = new LevelOneGen(currentElevation, levelWidth, currentDifficulty, alienTileset);
			
			var newChunk : Chunk = levGen.GenerateLevel();
			
			currentDifficulty = levGen.difficulty;
			
			startLevelX = endX;
			AddChunk(newChunk);
			endLevelX = endX;
			
			//Generate end of level chunk
			var endChunk : Chunk = Chunk.GenFlatChunk(50, currentElevation, alienTileset);
			
			AddChunk(endChunk);
		}
		
		private function AddChunk(chunk : Chunk) : void {
			if (firstChunk == null) {
				firstChunk = chunk;
			}
			if (lastChunk != null) {
				lastChunk.nextChunk = chunk;
			}
			lastChunk = chunk;
			
			bgLayer.add(chunk.bgTiles);
			midLayer.add(chunk.mainTiles);
			fgLayer.add(chunk.fgTiles);
			
			entities.add(chunk.entities);
			chunk.SetX(endX);
			
			endX += chunk.width;
			currentElevation = chunk.endElevation;
		}
		
		//removes the first chunk in the list and changes the first chunk to be the next one.
		private function RemoveFirstChunk() : void {
			bgLayer.remove(firstChunk.bgTiles);
			midLayer.remove(firstChunk.mainTiles);
			fgLayer.remove(firstChunk.fgTiles);
			entities.remove(firstChunk.entities);

			firstChunk = firstChunk.nextChunk;
		}
		
		override public function update():void 
		{
			FlxG.worldBounds.x = player.x - 64;
			FlxG.worldBounds.y = player.y - CommonConstants.WINDOWHEIGHT + 64;

			//check collisions
			FlxG.overlap(midLayer, player, player.collideTilemap);
			FlxG.collide(midLayer, entities, this.spriteCollisions);
			FlxG.overlap(player, entities, this.spriteCollisions);
			FlxG.overlap(entities, entities, this.spriteCollisions);
			
			updateCamera();
			

			//player falls off the world
			if (player.y > CommonConstants.LEVELHEIGHT * CommonConstants.TILEHEIGHT) {
				player.health = 0;
			}
			
			if (player.health == 0) {
				FlxG.resetState();
			}
			
			//end of level
			if (player.state != "levelEnd" && player.x > endLevelX) {
				player.state = "levelEnd";
				hud.DisplayLevelComplete();
				GenLevel();
				RemoveFirstChunk();
			}
			
			if (player.state == "levelEnd") {
				if(player.x > startLevelX - 200){
					player.state = "ground";
					hud.RemoveLevelComplete();
					RemoveFirstChunk();
				}	
			}
			
			super.update();
		}
		
		
		public function updateCamera() : void {
			var camera : FlxCamera = FlxG.camera;
			var playerPoint : FlxPoint = player.getFocusPoint();
			playerPoint.x += camera.width / 2 - 64;
			playerPoint.y -= 15;
			camera.focusOn(playerPoint);
		}
		
		public function spriteCollisions(sprite1:FlxObject, sprite2:FlxObject) : void {
			if (sprite1 is Player) {
				if (sprite2 is Collectible) {
					var col : Collectible = sprite2 as Collectible;
					col.playerCollide(sprite1 as Player);
				}
				if (sprite2 is Enemy) {
					var en : Enemy = sprite2 as Enemy;
					en.collidePlayer(sprite1 as Player);
				}
			}
			else if (sprite1 is Enemy) {
				if (sprite2 is Enemy) {
					(sprite1 as Enemy).collideEnemy(sprite2 as Enemy);
				}
			}
			else if (sprite1 is FlxTilemap) {
				if (sprite2 is Enemy) {
					(sprite2 as Enemy).collideTilemap(sprite1 as FlxTilemap);
				}
			}
		}
		
	}
	
}