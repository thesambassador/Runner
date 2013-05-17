package  
{
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.geom.Point;
	import org.flashdevelop.utils.FlashConnect;
	import org.flixel.*;
	/**
	 * ...
	 * @author ...
	 */
	public class MovingPlatform extends Entity
	{
		[Embed(source = '../resources/img/balloon.png')]private static var balloon:Class;
		
		public var shape : Shape;
		public var anchor : FlxPoint;
		public var topSpeed : int = 150;
		public var minSpeed : int = 20;
		public var smooth : Boolean = false;
		
		public function MovingPlatform(xStart:int = 0, yStart:int = 0, anchorX : int = 0, anchorY : int = 0) 
		{
			super(xStart, yStart);
			
			this.anchor = new FlxPoint(anchorX, anchorY);
			
			this.immovable = true;
			this.loadGraphic(balloon, false, false);
			
			this.allowCollisions = FlxObject.UP;
			
			this.width = 54;
			this.height = 32;
			
			this.offset.y += 10;
			this.offset.x += 5;
			
			shape = new Shape();
		}
		
		override public function setX(desiredX : Number) : void {
			this.x += desiredX;
			for each(var node : FlxPoint in this.path.nodes) {
				node.x += desiredX;
			}
			//this.anchor.x += desiredX;
		}
		
		override public function update() : void {
			if (this._pathMode == 0) {
				this.followPath(this.path, topSpeed, FlxObject.PATH_LOOP_BACKWARD);
			}
			
			if (this.path.nodes.length == 2 && smooth) {
				var prevNodeIndex : int = this._pathNodeIndex == 0 ? 1 : 0;
				
				var fromPoint : FlxPoint = this.path.nodes[prevNodeIndex] as FlxPoint;
				var targetPoint : FlxPoint = this.path.nodes[this._pathNodeIndex] as FlxPoint;
				var currentPoint : FlxPoint = new FlxPoint(this.x, this.y); //this.getMidpoint();
				
				var totalDist : Number = FlxU.getDistance(fromPoint, targetPoint);
				var currDist : Number = FlxU.getDistance(currentPoint, targetPoint);
				
				var progress : Number = currDist / totalDist;
				if (progress < 1) {	
					if(currDist > .5 * totalDist){
						this.pathSpeed = minSpeed + (1 - progress) * (topSpeed - minSpeed);
					}
					else if (currDist < .5 * totalDist){
						this.pathSpeed = minSpeed + progress * (topSpeed - minSpeed);
					}
				}
				else {
					var x = 5;
				}
			}
				
			super.update();
		}
		
		override public function draw() : void {
			super.draw();
			//drawVines(this.x, this.y, anchor.x, anchor.y);
		}
		
		public function drawVines(startX : int, startY: int, endX : int, endY : int) {
			var shape : Shape = new Shape();
			shape.graphics.lineStyle(1, 0x008800);
			shape.graphics.moveTo(0, Math.abs(startY - endY) - 1);
			shape.graphics.lineTo(Math.abs(startX - endX) - 1, 0);
			
			var sprite : FlxSprite = new FlxSprite(startX, startY);
			sprite.framePixels = new BitmapData(shape.width, shape.height, true, 0x00000000);
			sprite.framePixels.draw(shape);
			
			sprite.draw();
		}
		
		override public function collidePlayer(player : Player) : void {
			
			if(separate(this, player)){
				//if (player.y + player.height <= this.y){
					player.velocity.y = topSpeed;
				//}
				
				player.currentPlatform = this;
			}
			
		}
		
	}

}