package net.mole.base 
{
	import flash.display.CapsStyle;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	/**
	 * The main class of a game.
	 * @author Mikael Myyrä
	 */
	public class Game extends Sprite
	{
		public var SWF_WIDTH:uint = 1280;
		public var SWF_HEIGHT:uint = 720;
		public var FPS:uint = 60;
		
		public var level:Level;
		public var camera:GameCamera;
		public var physics:GamePhysics;
		
		private var _keysPressed:Vector.<uint> = new Vector.<uint>();
		public function get keysPressed():Vector.<uint> { return _keysPressed; }
		
		/**
		 * Create a new game
		 */
		public function Game():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}

		/**
		 * Create all objects needed. Called after everything is loaded.
		 */
		protected function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			addEventListener(Event.ENTER_FRAME, enterFrame);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
			stage.addEventListener(MouseEvent.CLICK, mouseClick);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheel);
			
			level = new Level(this);
			camera = new GameCamera(this);
			physics = new GamePhysics(this);
		}
		
		protected function enterFrame(e:Event):void 
		{
			physics.update();
			camera.update();
		}
		
		protected function keyDown(e:KeyboardEvent):void 
		{
			for each (var p:uint in _keysPressed) if (p == e.keyCode) return;
			
			var i:int = _keysPressed.indexOf(null);
			if (i >= 0) _keysPressed[i] = e.keyCode;
			else _keysPressed.push(e.keyCode);
			
			handleKeyEvent(_keysPressed);
		}
		
		protected function keyUp(e:KeyboardEvent):void 
		{
			_keysPressed[_keysPressed.indexOf(e.keyCode)] = null;
			
			handleKeyEvent(_keysPressed);
		}
		
		public function handleKeyEvent(keys:Vector.<uint>):void
		{
			level.handleKeyEvent(keys);
		}
		
		public function mouseClick(e:MouseEvent):void { }
		
		public function mouseDown(e:MouseEvent):void { }
		
		public function mouseUp(e:MouseEvent):void { }
		
		public function mouseWheel(e:MouseEvent):void { }
		
		
		public function onLoadLevel():void { }
		
		public function onLevelLoaded():void { }
		
		public function onLoadError(message:String):void
		{
			trace("Error loading level: " + message);
		}
	}
}