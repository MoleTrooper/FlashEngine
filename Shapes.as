package net.mole.base 
{
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author Mikael Myyrä
	 */
	public class Shapes 
	{	
		public static const CIRCLE:HBCircle = new HBCircle();
		
		public static const RECTANGLE:HBPolygon = new HBPolygon(new <Vector3D>[new Vector3D( -1, -1), new Vector3D(1, -1), new Vector3D(1, 1), new Vector3D( -1, 1)]);
		public static const TRIANGLE:HBPolygon = new HBPolygon(new <Vector3D>[new Vector3D(-1, 0), new Vector3D(0, -1), new Vector3D(1, 0)]);
		
		public function Shapes() { }
		
	}
}