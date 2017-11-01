package net.mole.base 
{
	/**
	 * ...
	 * @author Mikael Myyrä
	 */
	public class AIAction 
	{
		protected var creature:Creature;
		protected var _chance:Number;
		public function get chance():Number { return _chance; }
		protected var _running:Boolean = false;
		public function get running():Boolean { return _running; }
		
		public function AIAction(creature:Creature, chance:Number = 1)
		{
			this.creature = creature;
			this._chance = chance;
		}
		
		public function start():void
		{
			_running = true;
			//override
		}
		
		public function update():void
		{
			//override
		}
		
		public function end():void
		{
			_running = false;
			//override
		}
	}
}