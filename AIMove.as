package net.mole.base 
{
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author Mikael Myyrä
	 */
	public class AIMove extends AIAction 
	{
		protected var path:Vector.<AIPathNode> = new Vector.<AIPathNode>();
		public var loop:Boolean = true;
		public var drawTarget:Boolean = false;
		
		protected var targetIndex:int = 0;
		protected var stopped:Boolean = false;
		protected var timeStopped:int = 0;
		
		public function AIMove(creature:Creature, path:Vector.<AIPathNode> = null, loop:Boolean = true)
		{
			super(creature);
			this.path = path;
			this.loop = loop;
		}
		
		override public function start():void 
		{
			super.start();
			targetIndex = 0;
		}
		
		override public function update():void 
		{
			if (_running)
			{
				if (stopped)
				{
					if (path[targetIndex].holdTime > timeStopped)
					{
						timeStopped++;
					}
					else
					{
						timeStopped = 0;
						targetIndex++;
						stopped = false;
						if (targetIndex >= path.length)
						{
							targetIndex = 0;
							if (!loop) end();
						}
					}
				}
				else if (creature.position.nearEquals(path[targetIndex].position, path[targetIndex].speed / 2))
				{
					stopped = true;
					creature.velocity = new Vector3D(0, 0);
				}
				else
				{
					creature.velocity = path[targetIndex].position.subtract(creature.position);
					creature.velocity.scaleBy(path[targetIndex].speed / creature.velocity.length);
				}
			}
		}
		
		public function addNode(node:AIPathNode, index:int = -1):void
		{
			if (index != -1)
			{
				for (var i:int = path.length; i > index; i--)
				{
					path[i] = path[i - 1];
				}
				path[index] = node;
			}
			else path.push(node);
		}
		
		public function setPath(nodes:Vector.<AIPathNode>, loop:Boolean = true):void
		{
			path = nodes;
			this.loop = loop;
			targetIndex = 0;
		}
	}
}