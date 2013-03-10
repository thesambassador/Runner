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
		[Embed(source = '../resources/img/alientileset.png')]private static var alienTileset:Class;
		[Embed(source = "../resources/lvls/alienlevel.csv", mimeType = "application/octet-stream")]private static var levelText:Class;
		
		public var levelChunk : Chunk;
		
		public var chunkGroup : FlxGroup;
		public var entityGroup : FlxGroup;
		
		public var player : Player;
		public var background : ScrollingBackground;
		public var level : FlxTilemap;
		
		//init
		public function StaticLevel() 
		{
			background = new ScrollingBackground();
			
			FlxG.state.add(background);
			
			chunkGroup = new FlxGroup();
			entityGroup = new FlxGroup();
			FlxG.state.add(chunkGroup);
			FlxG.state.add(entityGroup);
			
			//create player and add it to the map
			player = new Player(getStartX(), getStartY() - 64);
			player.health = 1;
			FlxG.state.add(player);

			//set camera and world bounds
			FlxG.camera.setBounds(0, 0, 100, CommonConstants.LEVELHEIGHT * CommonConstants.TILEHEIGHT);
			FlxG.worldBounds = new FlxRect(0, 0, CommonConstants.WINDOWWIDTH + 128, CommonConstants.WINDOWHEIGHT + 128);
			
			GenLevel();

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
			var playerPoint : FlxPoint = player.getFocusPoint();
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
			
			levelChunk = new Chunk(alienTileset, 200, 20);
			
			level = new FlxTilemap();
			level.loadMap(levelString, alienTileset, 16, 16);
			
			levelChunk.allLayers.remove(levelChunk.mainTiles);
			
			levelChunk.mainTiles = level;
			
			levelChunk.allLayers.add(levelChunk.mainTiles);
			
			levelChunk.Decorate();
			
			var starBlocks : Array = level.getTileInstances(16);
			

			//level.setTileProperties(16, FlxObject.ANY, starCallback, MeleeAttack);
			level.setTileProperties(19, FlxObject.NONE);
			level.setTileProperties(20, FlxObject.NONE);
			level.setTileProperties(21, FlxObject.NONE);
			level.setTileProperties(11, FlxObject.UP);
			level.setTileProperties(12, FlxObject.UP);
			level.setTileProperties(13, FlxObject.UP);

			
			//chunkGroup.add(levelChunk.allLayers);
			chunkGroup.add(levelChunk.allLayers);
		}
		
		public function starCallback(Tile:FlxTile, obj:FlxObject) : Boolean {
			level.setTileByIndex(Tile.mapIndex, 0);
			return true;
		}

	}

}