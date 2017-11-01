package net.mole.base 
{
	/**
	 * Unused for now, not sure what to do with this
	 * @author Mikael Myyrä
	 */
	public class AIManager 
	{
		private var _creature:Creature;
		public function get creature():Creature { return _creature; }
		private var actions:Vector.<AIAction> = new Vector.<AIAction>();
		
		public function AIManager(creature:Creature)
		{
			this._creature = creature;
		}
		
		public function addAction(action:AIAction, priority:uint = 0):void
		{
			if (priority > actions.length) priority = 0;
			if (priority == 0)
			{
				actions.push(action);
			}
			else
			{
				for (var i:int = actions.length; i > priority; i--)
				{
					actions[i] = actions[i - 1];
				}
				actions[priority] = action;
			}
		}
		
		public function update():void
		{
			for (var i:int = 0; i < actions.length; i++)
			{
				if (Math.random() < actions[i].chance)
				{
					actions[i].start();
					
					break;
				}
			}
		}
	}
}