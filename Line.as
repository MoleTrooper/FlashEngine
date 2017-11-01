package net.mole.base 
{
	import flash.geom.Vector3D;
	/**
	 * Static line that objects can collide with.
	 * @author Mikael Myyrä
	 */
	public class Line 
	{
		private var _asVector:Vector3D;
		public function get asVector():Vector3D { return _asVector; }
		private var _center:Vector3D;
		public function get center():Vector3D { return _center; }
		
		private var _startPoint:Vector3D;
		public function get startPoint():Vector3D { return _startPoint; }
		private var _endPoint:Vector3D;
		public function get endPoint():Vector3D { return _endPoint; }
		private var _length:Number;
		public function get length():Number { return _length; }
		
		private var _friction:Number;
		public function get friction():Number { return _friction; }
		private var _elasticity:Number;
		public function get elasticity():Number { return _elasticity; }
		
		public var visible:Boolean;
		public var color:Number;
		
		public function Line(visible:Boolean = true, startX:Number = 0, startY:Number = 0, endX:Number = 0, endY:Number = 0, color:Number = 0x000000, friction:Number = 0.2, elasticity:Number = 0.8)
		{
			_startPoint = new Vector3D(startX, startY);
			_endPoint = new Vector3D(endX, endY);
			_friction = friction;
			_elasticity = elasticity;
			this.visible = visible;
			this.color = color;
			
			_asVector = new Vector3D(_endPoint.x - _startPoint.x, _endPoint.y - _startPoint.y);
			_center = _asVector.clone();
			_center.scaleBy(0.5);
			_center.incrementBy(_startPoint);
			_length = _asVector.length;
		}
		
		public function clone(startX:Number, startY:Number, endX:Number, endY:Number):Line
		{
			return new Line(visible, startX, startY, endX, endY, color, _friction, _elasticity);
		}
	}
}