package  
{
	import org.flixel.system.FlxList;
	import org.flixel.*;

	/**
	 * Each "chunk" will be 1-2 screen widths of a level, stored as a FlxTilemap
	 * We will have 4-5 chunks "active" or "loaded" at a time.  As the player moves forward, it will unload the "first" chunk (farthest left) and load a new "last" chunk (farthest right).
	 * 
	 */
	public class EndlessLevel 
	{
		[Embed(source = '../resources/img/alientileset.png')]private static var alienTileset:Class;
		
		private var firstChunk : Chunk ; //first chunk
		private var lastChunk : Chunk ; //last chunk
		private var chunkGen : ChunkGen;
		public var chunkNum : Number = 0; //number of chunks currently active
		private var chunkLimit : Number = 10; //number of chunks allowed at once before we start removing them
		
		public var chunkGroup : FlxGroup;
		public var entityGroup : FlxGroup;
		
		public var player : Player;
		//public var proj : Projectile;
		
		//init
		public function EndlessLevel() 
		{
			
			chunkGen = new LevelOneChunkGen();
			
			chunkGroup = new FlxGroup();
			entityGroup = new FlxGroup();
			FlxG.state.add(chunkGroup);
			FlxG.state.add(entityGroup);
			
			//create player and add it to the map
			player = new Player(getStartX(), getStartY());
			player.health = 1;
			FlxG.state.add(player);
			
			//var enemy:Enemy = new Enemy(getStartX()+100, getStartY());
			//var group:FlxGroup = new FlxGroup();
			
			
			
			//set camera and world bounds
			FlxG.camera.setBounds(0, 0, 100, CommonConstants.LEVELHEIGHT * CommonConstants.TILEHEIGHT);
			FlxG.worldBounds = new FlxRect(0, 0, CommonConstants.TILEWIDTH * 32, CommonConstants.TILEHEIGHT * 8);
			
			FlxG.watch(this, "chunkNum", "Chunk Num");
		}
		
		
		public function getStartX() : Number {
			return CommonConstants.TILEWIDTH * 10;
		}
		public function getStartY() : Number {
			return  (CommonConstants.LEVELHEIGHT - 5) * CommonConstants.TILEHEIGHT;
		}
		
		
		
		public function update() {
			
			FlxG.worldBounds.x = player.x - 64;
			FlxG.worldBounds.y = player.y;
			
			//check collisions
			FlxG.collide(chunkGroup, player, player.collideTilemap);
			FlxG.collide(chunkGroup, entityGroup);
			FlxG.collide(entityGroup, player, this.EnemyCollideWithPlayer);
			
			
			var camera : FlxCamera = FlxG.camera;
			var playerPoint : FlxPoint = player.getMidpoint();
			playerPoint.x += camera.width / 2 - 64;
			camera.focusOn(playerPoint);
			
			camera.setBounds(0, 0, player.x + 1000, CommonConstants.LEVELHEIGHT * CommonConstants.TILEHEIGHT);
			
			//player falls off the world
			if (player.y > CommonConstants.LEVELHEIGHT * CommonConstants.TILEHEIGHT) {
				player.health = 0;
			}
			
			if (player.health == 0) {
				FlxG.resetState();
			}
			
			//if (player.x > chunkGen.currentX - (CommonConstants.TILEWIDTH * 32)) {
			if(chunkNum < chunkLimit) {
				AppendNewChunk();
				//midChunkRight += chunkWidthPixels;
			}
			if (chunkNum > chunkLimit) {
				//RemoveFirstChunk();
			}
		}
		
		private function AppendNewChunk() : void {
			//create new chunk
			var newChunk : Chunk = chunkGen.GenerateChunk();

			chunkGroup.add(newChunk.allLayers);
			if(newChunk.entities.length > 0)
				entityGroup.add(newChunk.entities);

			//append it to the list
			if (firstChunk == null) {
				firstChunk = newChunk;
				lastChunk = newChunk;
			}
			else{
				lastChunk.nextChunk = newChunk;
				lastChunk = newChunk;
			}
			
			chunkNum ++;

		}
		
		private function RemoveFirstChunk() : void {
			var chunk1 : Chunk = firstChunk;
			chunkGroup.remove(chunk1.allLayers);
			entityGroup.remove(chunk1.entities);
			firstChunk = firstChunk.nextChunk;
			chunkNum --;
		}
		
		
		public function EnemyCollideWithPlayer(enemy:FlxObject, player:FlxObject) {
			var playerSprite : FlxSprite = player as FlxSprite;
			var enemySprite : FlxSprite = enemy as FlxSprite;
			if (enemy.health > 0) {
				if (enemy.y - playerSprite.y > 16) {
					playerSprite.velocity.y -= 300;
					enemy.health = 0;
				}
				else {
					playerSprite.health -= 1;
				}
			
			}
		}

	}

}