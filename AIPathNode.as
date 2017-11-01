package net.mole.base 
{
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author Mikael Myyrä
	 */
	public class AIPathNode 
	{
		public var position:Vector3D;
		public var speed:Number;
		public var holdTime:Number;
		
		public function AIPathNode(x:Number, y:Number, speed:Number, holdTime:Number)
		{
			position = new Vector3D(x, y);
			this.speed = speed;
			this.holdTime = holdTime;
		}
	}
}