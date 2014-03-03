package  
{
	import org.flixel.FlxPoint;
	import org.flixel.FlxText;
	/**
	 * ...
	 * @author Sam Tregillus
	 */
	public class CountText extends FlxText
	{
		public var startVal : int;
		public var curVal : int;
		public var endVal : int;
		public var delay : int;
		public var curDelay : int;
		
		public var increment : int = 1;
		
		public var going : Boolean = false;
		public var done : Boolean = false;
		
		public function CountText(x:Number, y:Number, width:int) {
			super(x, y, width, "0");
			this.scrollFactor = new FlxPoint();
			this.alignment = "center";
		}
		
		public function start(sVal : int, eVal : int, delayVal : int) : void {
			delay = delayVal;
			startVal = sVal;
			curVal = sVal;
			endVal = eVal;
			curDelay = 0;
			going = true;
			done = false;
		}
		
		override public function update() : void {
			if (going) {
				this.text = curVal.toString();
				curDelay ++;
				if (curDelay == delay) {
					if (curVal >= endVal) {
						done = true;
						going = false;
					}
					else {
						if (curVal + increment > endVal) {
							curVal = endVal;
						}
						else{
							curVal += increment;
						}
						curDelay = 0;
					}
				}
			}
			super.update();
		}
		
	}

}