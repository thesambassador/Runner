package  
{
	import org.flixel.FlxSprite;
	import org.flixel.FlxTilemap;
	import org.flixel.FlxG;
	import org.flixel.FlxObject;
	/**
	 * ...
	 * @author ...
	 */
	public class Entity extends FlxSprite
	{
		public var activated : Boolean = false;
		public var activationDistance : int = 300;
		public var origPosX : Number;
		public var origPosY : Number;
		
		public function Entity(startX:int = 0, startY:int = 0) 
		{
			super(startX, startY);
		}
		
		public function SetInitialPosition(ox : Number, oy:Number) {
			origPosX = ox;
			origPosY = oy;
			this.x = ox;
			this.y = oy;
		}
		
		public function behavior() : void {
			
		}
		
		public function checkActivation() : void {
			var playerX : int = FlxG.worldBounds.left + 256;
			
			if (this.x - playerX < activationDistance) 
				activated = true;
		}
		
		public function ResetToOriginal() {
			this.health = 1;
			this.facing = FlxObject.LEFT;
			reset(origPosX, origPosY);
		}
		
		override public function update() : void {
			checkActivation();
			//only update if in the world bounds and this has been activated
			if(this.x >= FlxG.worldBounds.left && this.x <= FlxG.worldBounds.right && activated){
				behavior();
			}
			else {
				PausedState();
			}
			super.update();
		}
		public function PausedState() :void {
			
		}
		
		public function collidePlayer(player : Player) : void {
			
		}
		
		public function collideEnemy(enemy : Entity) : void {
			
		}
		
		public function collideTilemap(tilemap : FlxTilemap) : void {
			
		}
		
	}

}