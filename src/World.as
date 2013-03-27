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
		
		public var bgLayer : FlxGroup; //background tiles
		public var midLayer: FlxGroup; //main/collision tiles
		public var fgLayer : FlxGroup; //foreground tiles
		
		public var entities : FlxGroup; //entities, excluding the player
		
		public var player : Player;
		public var background : ScrollingBackground;
		
		public var levelWidth : int = 400;
		
		public var firstChunk : Chunk;
		public var lastChunk : Chunk;
		public var numChunks : int;
		public var endX : int; //end of the level so far, this is the right side of the last generated chunk
		public var currentElevation : int; //last elevation, in tile coordinates, so that the next level/chunk will be started at the right level.
		
		public var playerStartX = CommonConstants.TILEWIDTH * 2;
		public var playerStartY = CommonConstants.TILEHEIGHT * .5 * CommonConstants.LEVELHEIGHT;
		
		public function World () {
			//background = new ScrollingBackground();
			//add(background);
			
			bgLayer = new FlxGroup();
			midLayer = new FlxGroup();
			fgLayer = new FlxGroup();
			
			add(bgLayer);
			add(midLayer);
			add(fgLayer);
			add(entities);
			
			player = new Player(playerStartX, playerStartY);
			add(player);
			
			//set camera and world bounds
			
			var camBoundY : int = CommonConstants.LEVELHEIGHT * CommonConstants.TILEHEIGHT - 20;
			
			FlxG.camera.setBounds(0, 0, 5000000000, camBoundY);
			FlxG.worldBounds = new FlxRect(0, 32, CommonConstants.WINDOWWIDTH + 128, CommonConstants.WINDOWHEIGHT + 128);
			
			CreateInitialPlatform();
			GenLevel();
		}
		
		private function CreateInitialPlatform() : void{
			var startPlatform : Chunk = new Chunk(alienTileset, 25);
			
			startPlatform.FillSolid(0, 35, 32, 29, 4);
			startPlatform.FillSolid(0, 34, 32, 1, 1);
			startPlatform.FillSolid(0, 0, 1, 34, 8);
			
			startPlatform.mainTiles.setTile(startPlatform.widthInTiles - 1, currentElevation, 11);
			
			AddChunk(startPlatform);
		}
		
		private function GenLevel() : void{
			var levGen : LevelGen = new LevelOneGen(currentElevation, levelWidth, 1, alienTileset);
			
			var newChunk : Chunk = levGen.GenerateLevel()
			newChunk.SetX(endX);
			
			AddChunk(newChunk);
		}
		
		private function AddChunk(chunk : Chunk) : void {
			if (firstChunk == null) {
				firstChunk = chunk;
			}
			lastChunk = chunk;
			
			bgLayer.add(chunk.bgTiles);
			midLayer.add(chunk.mainTiles);
			midLayer.add(chunk.entities);
			fgLayer.add(chunk.fgTiles);
			
			endX += chunk.width;
			currentElevation = chunk.endElevation;
		}
		
		private function RemoveFirstChunk() : void {
			bgLayer.remove(firstChunk.bgTiles);
			midLayer.remove(firstChunk.mainTiles);
			fgLayer.remove(firstChunk.fgTiles);

			firstChunk = firstChunk.nextChunk;
		}
		
		override public function update():void 
		{
			FlxG.worldBounds.x = player.x - 64;
			FlxG.worldBounds.y = player.y - CommonConstants.WINDOWHEIGHT + 64;

			//check collisions
			FlxG.overlap(midLayer, player, player.collideTilemap);
			//FlxG.collide(chunkGroup, entityGroup);
			//FlxG.collide(entityGroup, player, this.EnemyCollideWithPlayer);
			
			updateCamera();
			

			//player falls off the world
			if (player.y > CommonConstants.LEVELHEIGHT * CommonConstants.TILEHEIGHT) {
				player.health = 0;
			}
			
			if (player.health == 0) {
				FlxG.resetState();
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
		
	}
	
}