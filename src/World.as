package 
{
	import org.flixel.*;

	
	/**
	 * This class will handle all of the actual gameplay stuff.  it will add the player, levels, background, and handle transitions between levels
	 */
	public class World extends FlxGroup
	{
		[Embed(source = '../resources/img/alientileset.png')]private static var alienTileset:Class;
		[Embed(source = '../resources/sound/SurgeRamizHaddad.MP3')]private static var music:Class;
		
		//difficulty parameters, set by the main menu
		public static var levelWidth : int = 200;
		public static var startingDifficulty : int = 1; //what level of difficulty the first level will contain
		public static var difficultyGain : int = 1; //how much the difficulty increases throughout each level
		
		public static var monsterAcceleration : Number = 10; //acceleration per level
		public static var maxMonsterDistance : Number = levelWidth * CommonConstants.TILEWIDTH; //maximum distance that the monster can fall behind
		public static var startingMinMonsterVel : Number = 150;
		public static var maxMinMonsterVelocity : Number = 225; //this is the fastest that the monster will go when he's closer than maxMonsterDistance
		
		public var startElevation : int = CommonConstants.LEVELHEIGHT / 2;
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
		
		
		
		public var firstChunk : Chunk;
		public var lastChunk : Chunk;
		public var numChunks : int;
		public var endX : int; //end of the level so far, this is the right side of the last generated chunk
		public var startLevelX : int //start of the latest level chunk, the is the LEFT side of the most recent level chunk
		public var startLevelY : int //start of the latest level chunk, the is the LEFT side of the most recent level chunk
		public var endLevelX : int; //end of the actual level so far, this is the right side of the last LEVEL chunk
		public var currentElevation : int; //last elevation, in tile coordinates, so that the next level/chunk will be started at the right level.
		
		public var heightMap : Array;
		public var heightMapEndIndex : int = 0;
	
		
		public var playerStartX : int  = CommonConstants.TILEWIDTH * 2;
		public var playerStartY : int = CommonConstants.TILEHEIGHT * startElevation - 32;
		
		
		public var monsterSprite : FlxSprite;
		public var monsterX : Number;
		public var monsterVel : Number = 125;
		public var minMonsterVelocity : Number = 150;
		
		public var shakeBoundary : Number = -750;
		public var shakeDelay : int = 90;
		public var shakeTimer : int = 0;
		
		public var levelEndTimer : FlxTimer;
		
		public var gameOver : Boolean = false;
		
		public function World () {
			
			FlxG.playMusic(music);
			
			currentDifficulty = startingDifficulty;
			minMonsterVelocity = startingMinMonsterVel;
			background = new ScrollingBackground();
			add(background);
			heightMap = new Array(500);
			
			bgLayer = new FlxGroup();
			midLayer = new FlxGroup();
			fgLayer = new FlxGroup();
			entities = new FlxGroup();
			particles = new FlxGroup();
			
			add(bgLayer);
			add(midLayer);
			player = new Player(playerStartX, playerStartY);
			monsterSprite = new FlxSprite();
			monsterSprite.makeGraphic(1000, 1000, 0x8800bb00);
			add(monsterSprite);
			add(entities);
			add(player);
			add(particles);
			add(fgLayer);
			
			//monsterX = -levelWidth * CommonConstants.TILEWIDTH;
			monsterX = -1000;
			monsterSprite.x = monsterX - 1000;
			
			hud = new HUD(this);
			add(hud);
			
			//set camera
			camera = new SmoothCamera(player, heightMap);
			FlxG.resetCameras(camera);
			
			FlxG.worldBounds = new FlxRect(0, 0, CommonConstants.WINDOWWIDTH + 512, CommonConstants.LEVELHEIGHT * CommonConstants.TILEHEIGHT);
			
			CreateInitialPlatform();
			GenLevel();
			
			FlxG.watch(this, "monsterX", "Monster X");
			FlxG.watch(this, "monsterVel", "Monster Vel");
			
			levelEndTimer = new FlxTimer();
		}
		
		private function CreateInitialPlatform() : void{
			var startPlatform : Chunk = Chunk.GenFlatChunk(25, startElevation, alienTileset);
			startPlatform.Decorate();
			
			Chunk.FillUnder(0, 0, startPlatform.mainTiles, 8);
			AddChunk(startPlatform);
		}
		
		private function GenLevel() : void{
			var levGen : LevelOneGen = new LevelOneGen(currentElevation, levelWidth, currentDifficulty, alienTileset);
			levGen.difficultyIncrease = difficultyGain;

			var newChunk : Chunk = levGen.GenerateLevel();
			
			currentDifficulty = levGen.difficulty;
			
			startLevelX = endX;
			startLevelY = (currentElevation-2) * CommonConstants.TILEHEIGHT;
			AddChunk(newChunk);
			endLevelX = endX;
			
			//Generate end of level chunk
			var endChunk : Chunk = Chunk.GenFlatChunk(50, currentElevation, alienTileset);
			endChunk.Decorate();
			
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
			
			mergeHeightmap(chunk.GetHeightmap());
			
			endX += chunk.width;
			currentElevation = chunk.endElevation;
		}
		
		private function mergeHeightmap(array : Array) : void { 
			for (var i:int = 0; i < array.length; i++) {
				heightMap[heightMapEndIndex] = array[i];
				heightMapEndIndex ++;
			}
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
			//basic game updating
			updateMonster();
			FlxG.worldBounds.x = player.x - 256;
			checkCollisions();

			
			if (gameOver) {
				if (FlxG.keys.justPressed("R")) 
					FlxG.resetState();
			}
			else {
				if (!player.alive && (levelEndTimer.finished || levelEndTimer.progress == 0)) {
					var respawn:FlxPoint = findClosestRespawn();
					camera.SetTargetY(respawn.y);
					camera.SetTargetX(respawn.x);
					camera.xDelay = .01;
					levelEndTimer = new FlxTimer();
					levelEndTimer.start(.5, 1, RestartLevel);
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
				if (player.x > startLevelX - 400) {
					currentLevel += 1;
					minMonsterVelocity += monsterAcceleration;
					if (minMonsterVelocity > maxMinMonsterVelocity) {
						minMonsterVelocity = maxMinMonsterVelocity;
					}
					player.state = "ground";
					hud.RemoveLevelComplete();
					RemoveFirstChunk();
				}	
			}
			
			super.update();
		}
		
		public function updateMonster() : void {
			var monsterDist : Number = Math.abs(player.x - monsterX);
			monsterVel = 300 * (monsterDist / maxMonsterDistance);
			if (monsterVel < minMonsterVelocity) {
				monsterVel = minMonsterVelocity;
			}
			if (monsterDist < 50) {
				monsterVel = 150;
			}
			
			monsterX += monsterVel * FlxG.elapsed;
			if (monsterX > player.x  && player.alive) {
				player.lives = 0;
				player.health = 0;
				SetGameOver();
			}
			else if (monsterX > player.x + shakeBoundary) {
				
				shakeTimer++;
				if (shakeTimer >= shakeDelay) {
					shakeTimer = 0;
					camera.shake(.005);
				}
			}
			else {
				shakeTimer = 0;
			}
			
			monsterSprite.x = monsterX - 1000;
		}
		
		public function checkCollisions() : void {
			//check collisions
			FlxG.overlap(midLayer, player, null, player.collideTilemap);
			FlxG.overlap(midLayer, entities, this.spriteCollisions);
			FlxG.overlap(player, entities, this.spriteCollisions);
			FlxG.overlap(entities, entities, this.spriteCollisions);
			
			FlxG.collide(particles, midLayer);
			
			//second pass over entities so that we can separate the ones that matter, since we don't do any separation in the playerCollide method of each entity.  
			//This lets us collide the player with multiple entities at once... mostly just the "crumbleTile"
			FlxG.overlap(player, entities, secondCollide);
			
			//player falls off the world
			if (player.y > CommonConstants.LEVELHEIGHT * CommonConstants.TILEHEIGHT) {
				player.health = 0;
			}
		}
		
		public function findClosestRespawn() : FlxPoint {
			var chunk : Chunk = firstChunk;
			var validPoint : FlxPoint;
			while (validPoint == null) {
				if (player.x > chunk.x + chunk.width || player.x < chunk.x) {
					chunk = chunk.nextChunk;
				}
				else {
					for (var i : int = 0; i < chunk.safeZones.length; i++) {
						var check : FlxPoint = chunk.safeZones[i] as FlxPoint;
						var checkX : Number = chunk.tileXToRealX(check.x);
						if (player.x < checkX) {
							if (i == 0) i++;
							validPoint = chunk.safeZones[i - 1];  //tilemap coords
							break;
						}
					}
					if (validPoint == null) {
						validPoint = chunk.safeZones[0];
					}
				}
			}
			
		
			
			return new FlxPoint(chunk.tileXToRealX(validPoint.x), validPoint.y * CommonConstants.TILEHEIGHT - 32);
		}
		
		public function SetGameOver() : void {
			gameOver = true;
			var top : FlxText = hud.DisplayCenteredText("Game Over");
			var bottom : FlxText = hud.DisplayCenteredText("Press R to restart");
			top.y -= 32;
			bottom.size = 10;
			
			CommonFunctions.addCoins(player.collectiblesCollected);
			CommonFunctions.saveScore(player.score);
		}
		
		public function RestartLevel(timer:FlxTimer) : void {
			timer.stop();
			var respawnPoint : FlxPoint = findClosestRespawn();
			
			player.health = 1;
			player.reset(respawnPoint.x, respawnPoint.y);
			//player.reset(this.startLevelX - 128, startLevelY);
			//player.collectiblesCollected = startLevelCollectibles;
			FlxG.worldBounds.x = player.x - 256;
			
			entities.callAll("ResetToOriginal");
			
			//FlxG.overlap(player, entities, clearCollided);
				
			
		}
		
		public function clearCollided(player:FlxObject, entity:FlxObject) : void {
			entity.kill();
		}
		
		public function secondCollide(sprite1:FlxObject, sprite2:FlxObject) : void {
			if (sprite1 is Player) {
				if (sprite2 is CrumbleTile) {
					FlxObject.separate(sprite1, sprite2);
				}
			}
		}
		
		public function spriteCollisions(sprite1:FlxObject, sprite2:FlxObject) : void {
			if (sprite1 is Player) {
				(sprite2 as Entity).collidePlayer(sprite1 as Player);
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