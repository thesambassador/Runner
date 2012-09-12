package 
{
	
	/**
	 * ...
	 * @author Sam Tregillus
	 */
	public class Grid 
	{
		public var width:Number;
		public var height:Number;
		
		public var data:Array;
		
		//initialize grid with a value of 0 to all grid elements
		public function Grid(w:Number, h:Number) {
			width = w;
			height = h;
			
			data = new Array(height);
			for (var y:int = 0; y < data.length; y++) {
				var row : Array = new Array(width);
				for (var x:int = 0; x < row.length; x++) {
					 row[x] = 0;
				}
				data[y] = row;
			}
		}
		
		public function convertToOneDimension() : Array {
			var returned : Array = new Array();
			
			for (var y:int = 0; y < data.length; y++) {
				for (var x:int = 0; x < data[y].length; x++) {
					returned.push(data[y][x]);
				}
			}
			return returned;
		}
		
		public function at(x:Number, y:Number):Number {
			return data[y][x];
		}
		
		public function setCellAt(x:Number, y:Number, value:Number):void {
			data[y][x] = value;
		}
		
		
		
	}
	
}