package  
{
	import flash.geom.Point;
	import org.flashdevelop.utils.FlashConnect;
	import org.flixel.*;
	/**
	 * ...
	 * @author ...
	 */
	public class MovingPlatform extends FlxSprite
	{
		
		public var pauseLength : int;  //time in frames to pause the platform at each location
		private var currentIndex : int;
		public var speed : Number;
		public var direction : int; //this is either 1 (for moving forward) or -1 (for moving backward)
		
		public function MovingPlatform(xStart:int, yStart:int, w:int = 48, h:int = 16) 
		{
			super(xStart, yStart);
			
			this.immovable = true;
			
			this.makeGraphic(w, h);
			
			this.path = new FlxPath();
			
			currentIndex = 0;
			speed = 100;
			direction = 1;
		}
		
		
		
		override public function update():void {
			var currPoint : Point = new Point(this.x, this.y);
			var destPoint : Point = new Point(path.nodes[currentIndex].x, path.nodes[currentIndex].y);
			
			//if distance between the current point and the destination point is smaller than the speed, just snap the platform to the destination point
			if (Point.distance(destPoint, currPoint) <= speed * (1/60)) {
				this.x = destPoint.x;
				this.y = destPoint.y;
				
				//increment the next point index
				this.currentIndex += this.direction;
				
				//if we've hit the end of the list, switch directions
				if (this.currentIndex == this.path.nodes.length) {
					this.direction = -1;
					currentIndex -= 2;
				}
				else if (this.currentIndex == -1) {
					this.direction = 1;
					currentIndex += 2;
				}
			}
			else{
				
				//get difference vector
				var diff : Point = new Point(destPoint.x - currPoint.x, destPoint.y - currPoint.y);
				
				diff.normalize(speed);
				
				this.velocity.x = diff.x;
				this.velocity.y = diff.y;
				
			}
			super.update();
		}
		
	}

}