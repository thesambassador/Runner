package  
{
	import org.flixel.FlxBasic;
	import org.flixel.FlxG;
	/**
	 * ...
	 * @author ...
	 */
	public class DelayManager extends FlxBasic
	{
		public static var _delayManagerInstance : DelayManager;
		
		public var delayTimes : Array;
		public var callbacks : Array;
		
		public function DelayManager() 
		{
			delayTimes = new Array();
			callbacks = new Array();
			FlxG.addPlugin(this);
		}
		
		public static function get DelayManagerInstance() : DelayManager {
			if (_delayManagerInstance == null) {
				_delayManagerInstance = new DelayManager();
			}
			return _delayManagerInstance;
		}
		
		public static function AddDelay(time : Number, callback : Function) {
			DelayManagerInstance.delayTimes.push(time);
			DelayManagerInstance.callbacks.push(callback);
		}
		
		override public function update() : void {
			for (var i:int = 0; i < delayTimes.length; i++) {
				delayTimes[i] -= FlxG.elapsed;
				if (delayTimes[i] <= 0) {
					var call : Function = callbacks[i];
					if (call) {
						call();
					}
					delayTimes.splice(i, 1);
					callbacks.splice(i, 1);
				}
			}
		}
		
	}

}