package net.mole.base 
{
	/**
	 * ...
	 * @author Mikael Myyrä
	 */
	public class MenuStyle
	{
		private var _incrementX:Boolean;
		public function get incrementX():Boolean { return _incrementX; }
		private var _incrementY:Boolean;
		public function get incrementY():Boolean { return _incrementY; }
		private var _gap:Number;
		public function get gap():Number { return _gap; }
		
		public function MenuStyle(incrX:Boolean, incrY:Boolean, gap:Number)
		{
			_incrementX = incrX;
			_incrementY = incrY;
			_gap = gap;
		}
	}

}