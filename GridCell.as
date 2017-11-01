package net.mole.base 
{
	/**
	 * ...
	 * @author Mikael Myyrä
	 */
	public class GridCell 
	{
		private var _objects:Vector.<int> = new Vector.<int>();
		public function get objects():Vector.<int> { return _objects; }
		private var _lines:Vector.<Line> = new Vector.<Line>();
		public function get lines():Vector.<Line> { return _lines; }
		
		public function GridCell()
		{
			
		}
		
		public function addObject(id:int):void
		{
			if (_objects.indexOf(id) < 0) _objects.push(id);
		}
		
		public function removeObject(id:int):void
		{
			var i:int = _objects.indexOf(id);
			if (i >= 0) _objects.splice(i, 1);
		}
		
		public function addLine(line:Line):void
		{
			if(_lines.indexOf(line) < 0) _lines.push(line);
		}
		
		public function removeLine(line:Line):void
		{
			var i:int = _lines.indexOf(line);
			if (i >= 0) _lines.splice(i, 1);
		}
	}
}