package net.mole.base 
{
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author Mikael Myyrä
	 */
	public class VectorHelper 
	{
		
		public function VectorHelper() {}
		
		
		public static function rotateVector(vec:Vector3D, angle:Number):void
		{
			var angleRad:Number = angle * Math.PI / 180;
			
			var x:Number = (vec.x * Math.cos(angleRad)) - (vec.y * Math.sin(angleRad));
			var y:Number = (vec.y * Math.cos(angleRad)) + (vec.x * Math.sin(angleRad));
			vec.x = x;
			vec.y = y;
		}
		
		public static function projectVector(vec:Vector3D, axis:Vector3D):Vector3D
		{
			var normAxis:Vector3D = axis.clone();
			if (normAxis.length != 1) normAxis.normalize();
			
			return new Vector3D(normAxis.x * normAxis.dotProduct(vec), normAxis.y * normAxis.dotProduct(vec));
		}
		
		public static function parallel(vec1:Vector3D, vec2:Vector3D):Boolean
		{
			var unitV1:Vector3D = vec1.clone();
			unitV1.normalize();
			var unitV2:Vector3D = vec2.clone();
			unitV2.normalize();
			var negativeV2:Vector3D = unitV2.clone();
			negativeV2.negate();
			return (unitV1.equals(unitV2) || unitV1.equals(negativeV2));
		}
		
		public static function angle(vec1:Vector3D, vec2:Vector3D):Number
		{
			var angle:Number = Math.acos(vec1.dotProduct(vec2) / (vec1.length * vec2.length));
			return vec1.x * -vec2.y + vec1.y * vec2.x < 0 ? angle : -angle;
		}
	}
}