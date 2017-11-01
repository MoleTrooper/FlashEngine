package net.mole.base 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Mikael Myyrä
	 */
	public class AnimationEvent extends Event
	{
		public static const ANIM_LOOP:String = "animLoop";
		public static const ANIM_END:String = "animEnd";
	
	
		public function AnimationEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}

	
		public override function clone():Event
		{
			return new AnimationEvent(type, bubbles, cancelable);
		}
	}
}