package net.mole.base 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * A basic UI button. Textures change when highlighted or pressed, and a function is executed on release of the mouse button.
	 * @author Mikael Myyrä
	 */
	public class Button extends Sprite
	{
		protected var currentTexture:GameTexture;
		
		public var normalTexture:GameTexture;
		public var highlightedTexture:GameTexture;
		public var pressedTexture:GameTexture;
		
		protected var onPress:Function;
		
		public function Button(x:Number, y:Number, normalTexture:GameTexture, onPress:Function, buttonMode:Boolean = false)
		{
			this.x = x;
			this.y = y;
			this.onPress = onPress;
			this.normalTexture = normalTexture;
			this.currentTexture = normalTexture;
			addChild(currentTexture);
			this.buttonMode = buttonMode;
			
			addEventListener(MouseEvent.ROLL_OVER, highlight);
			addEventListener(MouseEvent.ROLL_OUT, endHighlight);
			addEventListener(MouseEvent.MOUSE_DOWN, press);
			addEventListener(MouseEvent.MOUSE_UP, release);
		}
		
		public function highlight(e:MouseEvent = null):void
		{
			if (highlightedTexture != null)
			{
				removeChild(currentTexture);
				currentTexture = highlightedTexture;
				addChild(currentTexture);
			}
			if (highlightedTexture is Animation)
			{
				(highlightedTexture as Animation).play();
				(highlightedTexture as Animation).finish();
			}
			//trace("mouse in");
		}
		
		public function endHighlight(e:MouseEvent = null):void
		{
			removeChild(currentTexture);
			currentTexture = normalTexture;
			addChild(currentTexture);
			//trace("mouse out");
		}
		
		public function press(e:MouseEvent = null):void
		{
			if (pressedTexture != null) currentTexture = pressedTexture;
			//trace("press");
		}
		
		private function release(e:MouseEvent = null):void 
		{
			onPress();
			if (highlightedTexture != null) currentTexture = highlightedTexture;
			//trace("release");
		}
	}
}