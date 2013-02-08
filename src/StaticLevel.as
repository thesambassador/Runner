package  
{
	import flash.utils.ByteArray;
	import org.flixel.system.FlxList;
	import org.flixel.*;
	import org.flixel.system.FlxTile;

	/**
	 * test level... not randomly generated, just a quick class that I duplicated to test player movement.
	 */
	public class StaticLevel 
	{
		[Embed(source = '../resources/img/auto_tiles.png')]private static var auto_tiles:Class;
		[Embed(source = '../resources/img/grasstileset.png')]private static var grass:Class;
		[Embed(source = "../resources/lvls/testLevel.csv", mimeType = "application/octet-stream")]private static var levelText:Class;
		
		private var firstChunk : Chunk ; //first chunk
		private var lastChunk : Chunk ; //last chunk
		private var chunkGen : ChunkGen;
		public var chunkNum : Number = 0; //number of chunks currently active
		private var chunkLimit : Number = 60; //number of chunks allowed at once before we start removing them
		
		public var chunkGroup : FlxGroup;
		public var entityGroup : FlxGroup;
		
		public var player : Player;
		public var level : FlxTilemap;
		
		//init
		public function StaticLevel() 
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
			
			//proj = new Projectile(160, 384);
			//FlxG.state.add(proj);
			
			//var enemy:Enemy = new Enemy(getStartX()+100, getStartY());
			//var group:FlxGroup = new FlxGroup();

			//set camera and world bounds
			FlxG.camera.setBounds(0, 0, 100, CommonConstants.LEVELHEIGHT * CommonConstants.TILEHEIGHT);
			FlxG.worldBounds = new FlxRect(0, 0, CommonConstants.WINDOWWIDTH + 128, CommonConstants.WINDOWHEIGHT + 128);
			
			GenLevel();
			
			FlxG.watch(FlxG.worldBounds, "x", "WorldX");
			FlxG.watch(FlxG.worldBounds, "y", "WorldY");
		}
		
		
		public function getStartX() : Number {
			return CommonConstants.TILEWIDTH * 3;
		}
		public function getStartY() : Number {
			return  (20 - 5) * CommonConstants.TILEHEIGHT;
		}

		public function update() : void{
			
			FlxG.worldBounds.x = player.x - 64;
			FlxG.worldBounds.y = player.y - CommonConstants.WINDOWHEIGHT + 64;
			
			if(player.attackProjectile != null)
				level.overlaps(player.attackProjectile)

			//check collisions
			FlxG.overlap(chunkGroup, player, player.collideTilemap);
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

		}
		

		public function EnemyCollideWithPlayer(enemy:FlxObject, player:FlxObject) : Boolean {
			var playerSprite : FlxSprite = player as FlxSprite;
			var enemySprite : FlxSprite = enemy as FlxSprite;
			if (enemy.health > 0) {
				if (enemy.y - playerSprite.y > 16) {
					playerSprite.velocity.y -= 300;
					enemy.health = 0;
					return true;
				}
				else {
					playerSprite.health -= 1;
					return true;
				}
			
			}
			return false;
		}
		
		public function GenLevel () : void {
			
			var b : ByteArray = new levelText();
			var levelString : String = b.readUTFBytes(b.length);
			
			level = new FlxTilemap();
			level.loadMap(levelString, grass, 16,16);
			
			var starBlocks : Array = level.getTileInstances(16);
			

			level.setTileProperties(16, FlxObject.ANY, starCallback, MeleeAttack);
			level.setTileProperties(28, FlxObject.NONE);
			level.setTileProperties(29, FlxObject.NONE);
			level.setTileProperties(30, FlxObject.NONE);
			level.setTileProperties(20, FlxObject.UP);
			level.setTileProperties(21, FlxObject.UP);
			level.setTileProperties(22, FlxObject.UP);

			
			chunkGroup.add(level);
		}
		
		public function starCallback(Tile:FlxTile, obj:FlxObject) : Boolean {
			level.setTileByIndex(Tile.mapIndex, 0);
			return true;
		}

	}

}