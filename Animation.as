package net.mole.base 
{
	import flash.display.Bitmap;
    import flash.display.BitmapData;
	import flash.display.DisplayObject;
    import flash.display.Loader;
	import flash.display.LoaderInfo;
    import flash.display.Sprite;
	import flash.display.Stage;
    import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
    import flash.net.URLRequest;
    import flash.text.TextField;
	import flash.utils.Timer;
	
	/**
	 * A simple tilesheet animation.
	 * @author Mikael Myyrä
	 */
	public class Animation extends GameTexture
	{
		
		private var tileSheet:BitmapData;
        private var frameData:BitmapData;
		
		private var rect:Rectangle;
        
		private var currentFrame:uint = 0;
		private var tileWidth:Number;
		private var tileHeight:Number;
		private var tileNumber:uint;
		private var delay:uint;
		private var currentDelay:uint = 0;
		
		private var _length:uint;
		public function get length():uint { return _length; }
		private var frames:uint;
		public var loops:int = -1;
		
		private var _playing:Boolean = false;
		public function get playing():Boolean { return _playing; }
		
		private var handleFinish:Function = null;
		
		/**
		 * Create a new Animation instance.
		 * @param	sheet	A tile sheet with all the animation's frames in Bitmap format.
		 * @param	delay	Delay between animation frames, in frames executed.
		 * @param	frames	Number of frames in the animation.
		 * @param	loopHandler	Handler function for when the animation loops but doesn't end.
		 * @param	endHandler	Handler function for when the animationt ends.
		 */
        public function Animation(sheet:Bitmap, delay:int, frames:uint, x:Number = 0, y:Number = 0, loopHandler:Function = null, endHandler:Function = null):void
		{
			super(null, x, y);
			
			tileWidth = sheet.width / frames;
			tileHeight = sheet.height;
			this.delay = delay;
			this.frames = frames;
			_length = frames * (delay + 1);
			
			rect = new Rectangle(0, 0, tileWidth, tileHeight);
			tileSheet = sheet.bitmapData;
			frameData = new BitmapData(rect.width, rect.height);
			bmp = new Bitmap(frameData);
			addChild(bmp);
			updateBitmap();
			
			_halfWidth = width / 2;
			_halfHeight = height / 2;
			
			if (loopHandler != null) addLoopHandler(loopHandler);
			if (endHandler != null) addEndHandler(endHandler);
        }
		
		override public function clone(x:Number = 0, y:Number = 0):GameTexture
		{
			return new Animation(new Bitmap(tileSheet), delay, frames, x, y);
		}
		
		
		/**
		 * Called every frame. Update the state of the animation.
		 */
		override public function update():void
		{
			doAnimation();
			updateBitmap();
		}
		
		/**
		 * Load the current frame from the tile sheet.
		 */
		protected function updateBitmap():void
		{
			frameData.lock();
			frameData.copyPixels(tileSheet, rect, new Point(0, 0));
			frameData.unlock();
		}
		
		/**
		 * Begin playback of the animation starting from the first frame.
		 * @param	loops	The number of times to loop the animation before stopping. Set to a negative value to keep looping indefinitely.
		 */
		public function play(loops:int = -1):void
		{
			stop();
			_playing = true;
			this.loops = loops;
		}
		
		/**
		 * Pause the animation without resetting it, to be continued or restarted later.
		 */
		public function pause():void
		{
			_playing = false;
		}
		
		/**
		 * Continue the animation from the frame it was left at.
		 */
		public function unpause():void
		{
			_playing = true;
		}
		
		/**
		 * Play the animation until the end of the current loop and then stops.
		 * @param	f	Function to execute when the animation stops.
		 */
		public function finish(f:Function = null):void
		{
			loops = 1;
			if (f != null)
			{
				handleFinish = f;
				addEventListener(AnimationEvent.ANIM_END, animFinishHandler);
			}
		}
		
		private function animFinishHandler(e:AnimationEvent):void 
		{
			if (handleFinish != null) handleFinish();
			removeEventListener(AnimationEvent.ANIM_END, animFinishHandler);
		}
		
		/**
		 * Stop and reset the animation to its first frame.
		 */
		public function stop():void
		{
			_playing = false;
			setFrame(0);
		}
		
		public function setFrame(frame:int):void
		{
			currentFrame = frame;
			currentDelay = 0;
			rect.x = currentFrame * tileWidth;
		}
		
		/**
		 * Handles playback of the animation.
		 */
		private function doAnimation():void
		{
			if (loops == 0) _playing = false;
			if (!_playing) return;
			
			if (currentDelay == delay)
			{
				if (currentFrame < frames)
				{
					currentFrame++;
				}
				else
				{
					//animation loops or ends
					currentFrame = 0;
					loops--;
					if (loops > 0) dispatchEvent(new AnimationEvent(AnimationEvent.ANIM_LOOP));
					else 
					{
						_playing = false;
						dispatchEvent(new AnimationEvent(AnimationEvent.ANIM_END));
					}
				}
				currentDelay = 0;
			}
			else
			{
				currentDelay++;
			}
			rect.x = currentFrame * tileWidth;
		}
		
		/**
		 * Add a handler function for when the animation loops but doesn't end.
		 * @param	f	Function to add.
		 */
		public function addLoopHandler(f:Function):void { addEventListener(AnimationEvent.ANIM_LOOP, f); }
		
		/**
		 * Add a handler function for when the animation ends.
		 * @param	f	Function to add.
		 */
		public function addEndHandler(f:Function):void { addEventListener(AnimationEvent.ANIM_END, f); }
		
		/**
		 * Remove a handler function for when the animation loops but doesn't end.
		 * @param	f	Function to remove.
		 */
		public function removeLoopHandler(f:Function):void { removeEventListener(AnimationEvent.ANIM_LOOP, f); }
		
		/**
		 * Remove a handler function for when the animation ends.
		 * @param	f	Function to remove.
		 */
		public function removeEndHandler(f:Function):void { removeEventListener(AnimationEvent.ANIM_END, f); }
		
		
		
    }
}