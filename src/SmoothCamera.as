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
		public var targetPoint : FlxPoint = new FlxPoint();
		public var actualPoint : FlxPoint = new FlxPoint();
		
		public var xOffset : int;
		public var yOffset : int;
		
		public var delay : Number = .01;
		
		public var lastY : int = 0;
		public var forwardY : int = 0;
		
		public var ignoreFirst : Boolean = true;
		
		public function SmoothCamera(player : Player) {

			super(0, 0, FlxG.width, FlxG.height);
			playerRef = player;
			
			var camBoundY : int = CommonConstants.LEVELHEIGHT * CommonConstants.TILEHEIGHT - 20;
			
			this.setBounds(0, 0, 5000000000, camBoundY);
			
			
			
			xOffset = this.width / 2 - 64;
			yOffset = -48;
		}
		
		public function SetTargetY(targetY : int) {
			if (Math.abs(targetY - lastY) > 4 * 16) {
				forwardY = targetY;
			}
		}
		
		override public function update() : void {
			if (ignoreFirst) { 
				ignoreFirst = false;
				focusOn(playerRef.getFocusPoint());
				actualPoint.y = playerRef.getFocusPoint().y;
			}
			else{
				targetPoint = playerRef.getFocusPoint();
				targetPoint.x += xOffset;
				
				if (forwardY == 0) forwardY = targetPoint.y;
				
				
				targetPoint.y = forwardY + yOffset;
				
				var diffy : Number = targetPoint.y - actualPoint.y;
				diffy *= delay;
				
				var potentialY : Number = targetPoint.y + diffy;
				var scrollY : Number = this.scroll.y;
				
				actualPoint.x = targetPoint.x;
				actualPoint.y += diffy;
				//actualPoint.y = forwardY;

				this.focusOn(actualPoint);
				
				lastY = forwardY;
				super.update();
			}
		}
		
		
		
	}
	
}