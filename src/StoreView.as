package 
{
	
	/**
	 * ...
	 * @author Sam Tregillus
	 */
	public class StoreView extends FlxGroup
	{
		public function StoreView() {
			super();
			
			FlxG.mouse.show();
				
			var background : FlxSprite = new FlxSprite();
			background.loadGraphic(CommonConstants.MENUBG);
			background.alpha = .8;
			add(background);
			
			InitializeStoreObjects();
		}
		
		public function InitializeStoreObjects() {
			
		}
		
		
		override public function add(object : FlxBasic) : FlxBasic{
			if (object is FlxGroup) {
				(object as FlxGroup).setAll("scrollFactor", new FlxPoint());
				super.add(object);
			}
			else if(object is FlxSprite){
				(object as FlxSprite).scrollFactor = new FlxPoint();
				super.add(object);
			}
			else {
				super.add(object);
			}
			return object;
		}
		
	}
	
}