package net.mole.base 
{
	/**
	 * An in-game object with AI.
	 * @author Mikael Myyrä
	 */
	public class Creature extends GameObject 
	{
		protected var ai:Vector.<AIAction> = new Vector.<AIAction>();
		
		public function Creature(level:Level, texture:GameTexture, x:Number=0, y:Number=0, hitBox:HitBox=null, width:Number=0, height:Number=0) 
		{
			super(level, texture, x, y, hitBox, width, height);
			
		}
		
		override public function update():void 
		{
			super.update();
			for (var i:int = 0; i < ai.length; i++)
			{
				ai[i].update();
			}
		}
	}
}