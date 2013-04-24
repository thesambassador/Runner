package 
{
	
	/**
	 * ...
	 * @author ...
	 */
	
	
	public class CrumbleTile extends Entity 
	{
		[Embed(source = '../resources/img/dissolveTile.png')]private static var cTile:Class;
		public function CrumbleTile(startX:int = 0, startY:int = 0) {
			super(startX, startY);
			super.loadGraphic(cTile, true, false, 16, 16);
			
			this.addAnimation("crumble", [0, 1, 2, 3, 4, 5, 6, 7, 8], 12, false);
			this.addAnimationCallback(animHandler);
			
			this.immovable = true;
		}
		
		public function animHandler(animName:String, frameNum:uint, frameIndex:uint) : void {
			if (animName == "crumble" && frameIndex >= 7) {
				this.kill();
			}
		}
		
		override public function collidePlayer(player : Player) : void {
			if(this._curAnim == null)
				this.play("crumble");
		
		}
		
		
	}
	
}