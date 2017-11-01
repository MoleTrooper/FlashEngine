package net.mole.base 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.errors.IllegalOperationError;
	import flash.events.GameInputEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	import flash.net.drm.AuthenticationMethod;
	
	/**
	 * An in-game object that can move and obey the laws of physics.
	 * @author Mikael Myyrä
	 */
	public class GameObject extends Sprite
	{
		protected var level:Level;
		public var ID:int = -1;
		
		protected var texture:GameTexture;
		protected var dropShadow:Bitmap;
		public var shadowOffset:Vector3D = new Vector3D();
		public var shadowSize:Number = 1;
		
		public var position:Vector3D = new Vector3D(0, 0);
		public var gridCell:Vector3D = new Vector3D(0, 0);
		public var moved:Boolean = false;
		
		private var drawPos:Vector3D = new Vector3D(0, 0);
		public function get drawPosition():Vector3D { return drawPos; }
		
		protected var _controllable:Boolean = false;
		public function get controllable():Boolean { return _controllable; }
		
		protected var _usePhysics:Boolean = true;
		public function get usePhysics():Boolean { return _usePhysics; }
		
		//------PHYSICS STUFF--------
		protected var _collidable:Boolean = true;
		public function get collidable():Boolean { return _collidable; }
		protected var _movable:Boolean = true;
		public function get movable():Boolean { return _movable; }
		protected var _hasGravity:Boolean = true;
		public function get hasGravity():Boolean { return _hasGravity; }
		
		protected var _hitBox:HitBox;
		public function get hitBox():HitBox { return _hitBox }
		
		public var velocity:Vector3D = new Vector3D(0, 0);
		public var angularVelocity:Number = 0;
		
		protected var _mass:Number = 1;
		public function get mass():Number { return _mass; }
		
		protected var _momentOfInertia:Number = 1;
		public function get momentOfInertia():Number { return _momentOfInertia; }
		
		protected var _elasticity:Number = 0.8;
		public function get elasticity():Number { return _elasticity; }
		protected var _friction:Number = 0.2;
		public function get friction():Number { return _friction; }
		
		
		public function GameObject(level:Level, texture:GameTexture, x:Number = 0, y:Number = 0, hitBox:HitBox = null, width:Number = 0, height:Number = 0)
		{
			this.level = level;
			
			position.x = x;
			position.y = y;
			
			this.texture = texture;
			addChild(this.texture);
			if (width != 0) texture.scaleX = width / texture.width;
			if (height != 0) texture.scaleY = height / texture.height;
			drawPos = new Vector3D(-texture.width / 2, -texture.height / 2);
			
			if (hitBox == null) this._collidable = false;
			else createHitbox(hitBox, texture.width, texture.height);
			
			update();
		}
		
		public function update():void 
		{
			texture.update();
			if (dropShadow != null) if (dropShadow.mask is Animation) (dropShadow.mask as Animation).update();
			handleKeys(level.game.keysPressed);
		}
		
		protected function createHitbox(hitBox:HitBox, width:Number, height:Number, offset:Vector3D = null):void
		{
			_hitBox = hitBox.scale(width, height);
			_hitBox.position = this.position;
			if (offset != null)
			{
				texture.x = -offset.x;
				texture.y = -offset.y;
			}
			_collidable = true;
		}
		
		protected function createDropShadow(offsetX:Number = 0, offsetY:Number = 0, size:Number = 1, color:Number = 0x50858585):void
		{
			shadowOffset = new Vector3D(offsetX, offsetY);
			var shadowBmp:BitmapData = new BitmapData(texture.width, texture.height, true, color);
			dropShadow = new Bitmap(shadowBmp);
			shadowSize = size;
			dropShadow.scaleX = size;
			dropShadow.scaleY = size;
			dropShadow.x = texture.x + shadowOffset.x;
			dropShadow.y = texture.y + shadowOffset.y;
			dropShadow.cacheAsBitmap = true;
			addChildAt(dropShadow, 0);
			var mask:GameTexture = texture.clone();
			mask.cacheAsBitmap = true;
			mask.x = dropShadow.x;
			mask.y = dropShadow.y;
			addChild(mask);
			dropShadow.mask = mask;
		}
		
		public function rotate(angle:Number):void
		{
			this.rotation += angle;
			if (_hitBox != null) _hitBox.rotate(angle);
			VectorHelper.rotateVector(drawPos, angle);
			VectorHelper.rotateVector(shadowOffset, -angle);
			dropShadow.x = texture.x + shadowOffset.x;
			dropShadow.y = texture.y + shadowOffset.y;
			dropShadow.mask.x = dropShadow.x;
			dropShadow.mask.y = dropShadow.y;
		}
		
		public function setRotation(angle:Number):void
		{
			var toRotate:Number = angle - rotation;
			rotate(toRotate);
		}
		
		public function setMass(m:Number):void
		{
			_mass = m;
			_momentOfInertia = _hitBox == null ? 1 : _hitBox.getMomentOfInertia(m);
		}
		
		public function setScale(scale:Number):void
		{
			this.scaleX = this.scaleY = scale;
		}
		
		public function clone(x:Number = 0, y:Number = 0):GameObject
		{
			return new GameObject(level, texture, x, y, _hitBox, texture.width, texture.height);
		}
		
		/**
		 * function called when this object collides with another
		 * @param	obj the object collided with
		 */
		public function onCollision(obj:GameObject):void { }
		
		/**
		 * called every frame, handles key presses
		 * @param	keysPressed Vector containing all keys currently pressed
		 */
		public function handleKeys(keysPressed:Vector.<uint>):void { }
	}
}