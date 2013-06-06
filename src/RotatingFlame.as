package  
{
	import org.flixel.FlxGroup;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	import org.flixel.FlxG;
	/**
	 * ...
	 * @author ...
	 */
	public class RotatingFlame extends Entity
	{
		[Embed(source = '../resources/img/FireBall.png')]private static var fireball:Class;
		
		public var currentAngle : Number = 0;
		public var speed : Number = 180;
		
		public var targetX : Number;
		public var targetY : Number;
		public var distance : Number;
		
		public function RotatingFlame(tX : Number, tY : Number, dist : Number, dspeed : Number = 180) {
			
			speed = dspeed;
			
			targetX = tX;
			targetY = tY;
			distance = dist;
			
			super();
			this.loadGraphic(fireball, true, false, 16, 16);
			
			this.x = targetX + dist;
			this.y = targetY;
		
		}
		
		override public function checkActivation() : void {
			var playerX : int = FlxG.worldBounds.left + 256;
			
			if (this.targetX - playerX < activationDistance) 
				activated = true;
		}
		
		override public function setX(desiredX : Number) : void{
			targetX += desiredX;
			this.x += desiredX;
		}
		
		override public function ResetToOriginal() : void {
			super.ResetToOriginal();
			currentAngle = 0;
		}
		
		override public function behavior() : void {
			currentAngle += speed * (1/60);
			if (currentAngle > 360) {
				currentAngle -= 360;
			}
			
			var point : FlxPoint = getVector(currentAngle, distance);
			
			this.x = targetX + point.x;
			this.y = targetY + point.y;

			//this.angle = currentAngle;
		}
		
		public function getVector(angle : Number, length : Number) : FlxPoint {
			var returned : FlxPoint = new FlxPoint();
			
			var radians : Number = angle * Math.PI/180

			returned.x = Math.cos(radians) * length;
			returned.y = Math.sin(radians) * length;
			
			return returned;
		}
		
		override public function collidePlayer(player : Player) : void {
			player.hurt(1);
		}
	}

}