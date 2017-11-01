package net.mole.base 
{
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author Mikael Myyrä
	 */
	public class HBCircle extends HitBox 
	{
		
		public function HBCircle(radius:Number = 1, x:Number = 0, y:Number = 0)
		{
			_radius = radius;
			position = new Vector3D(x, y);
		}
		
		public override function scale(scaleX:Number, scaleY:Number):HitBox
		{
			var rad:Number = scaleX > scaleY ? scaleX / 2 : scaleY / 2;
			return new HBCircle(rad);
		}
		
		public override function getType():String 
		{
			return "circle";
		}
	}
}