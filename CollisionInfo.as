package net.mole.base 
{
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author Mikael Myyrä
	 */
	public class CollisionInfo 
	{
		public var penetration:Vector3D = new Vector3D();
		public var distance:Vector3D = new Vector3D();
		public var forcePosition:Vector3D;
		
		public function CollisionInfo() 
		{
			
		}
	}
}