package net.mole.base 
{
	import flash.geom.Vector3D;
	
	/**
	 * ...
	 * @author Mikael Myyrä
	 */
	public class HitBox 
	{
		public var position:Vector3D;
		protected var _radius:Number = 0;
		public function get radius():Number { return _radius; }
		
		public function HitBox() { }
		
		public function getType():String { return "none" }
		public function scale(scaleX:Number, scaleY:Number):HitBox { return new HitBox() }
		public function rotate(angle:Number):void { }
		
		public function getMomentOfInertia(mass:Number):Number
		{
			return _radius * _radius * mass;
		}
	}
}