package 
{
	import org.flixel.*;

	
	/**
	 * This class will handle all of the actual gameplay stuff.  it will add the player, levels, background, and handle transitions between levels
	 */
	public class World extends FlxGroup
	{
		[Embed(source = '../resources/img/alientileset.png')]private static var alienTileset:Class;
		
		public var startElevation : int = 32;
		
		public var levelChunk : Chunk;
		public var currentDifficulty : int = 1;
		public var currentLevel : int = 1;

		public var hud : HUD; //ui group
		public var bgLayer : FlxGroup; //background tiles
		public var midLayer: FlxGroup; //main/collision tiles
		public var particles: FlxGroup; //main/collision tiles
		public var fgLayer : FlxGroup; //foreground tiles
		
		public var entities : FlxGroup; //entities, excluding the player
		
		public var player : Player;
		public var camera : SmoothCamera;
		public var background : ScrollingBackground;
		
		public var levelWidth : int = 300;
		
		public var firstChunk : Chunk;
		public var lastChunk : Chunk;
		public var numChunks : int;
		public var endX : int; //end of the level so far, this is the right side of the last generated chunk
		public var startLevelX : int //start of the latest level chunk, the is the LEFT side of the most recent level chunk
		public var startLevelY : int //start of the latest level chunk, the is the LEFT side of the most recent level chunk
		public var endLevelX : int; //end of the actual level so far, this is the right side of the last LEVEL chunk
		public var currentElevation : int; //last elevation, in tile coordinates, so that the next level/chunk will be started at the right level.
		
		public var startLevelCollectibles : int = 0;
		
		public var playerStartX : int  = CommonConstants.TILEWIDTH * 2;
		public var playerStartY : int = CommonConstants.TILEHEIGHT * startElevation - 32;
		
		public function World () {
			//background = new ScrollingBackground();
			//add(background);
			
			
			bgLayer = new FlxGroup();
			midLayer = new FlxGroup();
			fgLayer = new FlxGroup();
			entities = new FlxGroup();
			particles = new FlxGroup();
			
			
			add(bgLayer);
			add(midLayer);
			add(entities);
			add(particles);
			add(fgLayer);
			
			player = new Player(playerStartX, playerStartY);
			add(player);
			
			hud = new HUD(player);
			add(hud);
			
			
			//set camera
			camera = new SmoothCamera(player);
			FlxG.resetCameras(camera);
			
			FlxG.worldBounds = new FlxRect(0, 32, CommonConstants.WINDOWWIDTH + 512, CommonConstants.WINDOWHEIGHT + 128);
			
			CreateInitialPlatform();
			GenLevel();
			
			FlxG.watch(this, "currentDifficulty", "diff");
		}
		
		private function CreateInitialPlatform() : void{
			var startPlatform : Chunk = Chunk.GenFlatChunk(25, startElevation, alienTileset);

			Chunk.FillUnder(0, 0, startPlatform.mainTiles, 8);
			AddChunk(startPlatform);
		}
		
		private function GenLevel() : void{
			var levGen : LevelGen = new LevelOneGen(currentElevation, levelWidth, currentDifficulty, alienTileset);
			
			var newChunk : Chunk = levGen.GenerateLevel();
			
			currentDifficulty = levGen.difficulty;
			
			startLevelX = endX;
			startLevelY = (currentElevation-2) * CommonConstants.TILEHEIGHT;
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
			FlxG.worldBounds.x = player.x - 256;
			FlxG.worldBounds.y = player.y - CommonConstants.WINDOWHEIGHT + 64;
			
			//check collisions
			FlxG.overlap(midLayer, player, null, player.collideTilemap);
			FlxG.overlap(midLayer, entities, this.spriteCollisions);
			FlxG.overlap(player, entities, this.spriteCollisions);
			FlxG.overlap(entities, entities, this.spriteCollisions);
			
			FlxG.collide(particles, midLayer);
			
	

			updateCamera();

			//player falls off the world
			if (player.y > CommonConstants.LEVELHEIGHT * CommonConstants.TILEHEIGHT) {
				player.health = 0;
			}
			
			if (player.health <= 0) {
				
				if (player.lives <= 0) {
					if(player.lives == 0){
						var top : FlxText = hud.DisplayCenteredText("Game Over");
						var bottom : FlxText = hud.DisplayCenteredText("Press R to restart");
						top.y -= 32;
						bottom.size = 10;
						player.lives --;
					}
					if (FlxG.keys.justPressed("R")) 
						FlxG.resetState();
				}
				else {
					player.lives --;
					player.health = 1;
					RestartLevel();
				}
			}
			
			//end of level
			if (player.state != "levelEnd" && player.x > endLevelX) {
				player.state = "levelEnd";
				hud.DisplayLevelComplete();
				GenLevel();
				RemoveFirstChunk();
			}
			
			if (player.state == "levelEnd") {
				startLevelCollectibles = player.collectiblesCollected;
				if (player.x > startLevelX - 400) {
					currentLevel += 1;
					player.state = "ground";
					hud.RemoveLevelComplete();
					RemoveFirstChunk();
				}	
			}
			
			super.update();
		}
		
		public function RestartLevel() : void {
			player.reset(this.startLevelX - 128, startLevelY);
			player.collectiblesCollected = startLevelCollectibles;
			
			camera.targetPoint.x = player.getFocusPoint().x;
			camera.targetPoint.y = player.getFocusPoint().y;
			camera.actualPoint.copyFrom(camera.targetPoint);
			
			entities.callAll("ResetToOriginal");
		}
		
		public function updateCamera() : void {
			for each(var tilemap : FlxTilemap in midLayer.members) {
				if(tilemap != null){
					var startPoint : FlxPoint = player.getFocusPoint();
					startPoint.x += 128;
					var endPoint : FlxPoint = new FlxPoint();
					startPoint.copyTo(endPoint);
					
					endPoint.y += 400;
					
					var result1 : FlxPoint = new FlxPoint();
					var result2 : FlxPoint = new FlxPoint();
					if (!tilemap.ray(startPoint, endPoint, result1)) {
						startPoint.x += 256;
						endPoint.x += 128;
						if (!tilemap.ray(startPoint, endPoint, result2)) {
							camera.SetTargetY((result1.y + result2.y) / 2);
						}
					}
				}
			}
		}
		
		public function spriteCollisions(sprite1:FlxObject, sprite2:FlxObject) : void {
			if (sprite1 is Player) {
				if (sprite2 is Collectible) {
					var col : Collectible = sprite2 as Collectible;
					col.collidePlayer(sprite1 as Player);
				}
				if (sprite2 is Entity) {
					var en : Entity = sprite2 as Entity;
					en.collidePlayer(sprite1 as Player);
				}
			}
			else if (sprite1 is Entity) {
				if (sprite2 is Entity) {
					(sprite1 as Entity).collideEnemy(sprite2 as Entity);
				}
			}
			else if (sprite1 is FlxTilemap) {
				if (sprite2 is Entity) {
					(sprite2 as Entity).collideTilemap(sprite1 as FlxTilemap);
				}
			}
		}
		
	}
	
}