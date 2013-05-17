package 
{
	import org.flixel.FlxCamera
	import org.flixel.FlxPoint;
	import org.flixel.FlxG;
	/**
	 * ...
	 * @author ...
	 */
	public class SmoothCamera extends FlxCamera
	{
		public var playerRef : Player; 
		public var heightmapRef : Array;
		public var targetPoint : FlxPoint = new FlxPoint();
		public var actualPoint : FlxPoint = new FlxPoint();
		
		public var xOffset : int;
		//public var normalXOffset : int;
		//public var monsterXOffset : int;
		public var yOffset : int;
		
		public var yDelay : Number = .01;
		public var xDelay : Number = 1;
		
		public var lastY : int = 0;
		public var forwardY : int = 0; //Y coordinate 20 tiles in front of the player
		public var focusY : int = 0 //actual point used to set camera
		
		public var focusPlayer : Boolean = false;
		
		public var ignoreFirst : Boolean = true;
		
		public function SmoothCamera(player : Player, heightMap : Array) {

			super(0, 0, FlxG.width, FlxG.height);
			playerRef = player;
			
			var camBoundY : int = CommonConstants.LEVELHEIGHT * CommonConstants.TILEHEIGHT - 20;
			
			this.setBounds(0, -64, 5000000000, camBoundY);
			
			heightmapRef = heightMap;
			
			xOffset = this.width / 2 - 64;
			yOffset = -48;
		}
		
		public function SetTargetY(targetY : int, force:Boolean = false) {
 			if (Math.abs(targetY - lastY) > 4 * 16 || force) {
				forwardY = targetY + yOffset;
				focusY = forwardY;
			}
			
			
		}
		
		public function SetTargetX(targetX : int) {
			targetPoint.x = targetX + xOffset;
		}
		
		override public function update() : void {
			//who even knows why i have to do this.  The camera is created, but the constructor won't have run yet for whatever reason on the very first frame of the game
			if (ignoreFirst) { 
				ignoreFirst = false;
				focusOn(playerRef.getFocusPoint());
				actualPoint.y = playerRef.getFocusPoint().y;
			}
			
			else {
				
				var playerPoint : FlxPoint = playerRef.getFocusPoint();
				//X stuff
				if(playerRef.alive)
					SetTargetX(playerPoint.x);
				if (xDelay < 1) {
					xDelay += .001;
				}
	
				var diffX : Number = targetPoint.x - actualPoint.x;
				diffX *= xDelay;
				actualPoint.x += diffX;
				
				var playerTileX : int = targetPoint.x / CommonConstants.TILEWIDTH;

				var heightAtTarget : int = heightmapRef[playerTileX + 20];
				if (heightAtTarget != -1) {
					SetTargetY(heightAtTarget * CommonConstants.TILEHEIGHT);
				}
				
				if (forwardY == 0) 
					SetTargetY(targetPoint.y, true);
				
				
					
				targetPoint.y = focusY;
				
				var diffy : Number = targetPoint.y - actualPoint.y;
				diffy *= yDelay;
				
				actualPoint.y += diffy;
				
				//don't let our player get off the screen
				var halfHeight : int = CommonConstants.WINDOWHEIGHT / 4;
				if (playerRef.alive && actualPoint.y + halfHeight < playerRef.y + 32) {
					targetPoint.y += 10;  
					focusY += 10;
				}
				else if (playerRef.alive && actualPoint.y - halfHeight > playerRef.y) {
					targetPoint.y -= 10;  
					focusY -= 10;
				}
				else {
					focusY = forwardY;
				}
				

				this.focusOn(actualPoint);
				
				lastY = forwardY;
				super.update();
			}
		}
		
		
		
	}
	
}