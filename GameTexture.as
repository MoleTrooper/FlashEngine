package net.mole.base 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author Mikael Myyrä
	 */
	public class GameTexture extends Sprite
	{
		protected var bmp:Bitmap;
		public function get bitmap():Bitmap { return bmp; }
		
		public var position:Vector3D = new Vector3D();
		
		protected var _halfWidth:Number;
		public function get halfWidth():Number { return _halfWidth; }
		protected var _halfHeight:Number;
		public function get halfHeight():Number { return _halfHeight; }
		
		public function GameTexture(bmp:Bitmap = null, x:Number = 0, y:Number = 0, scale:Number = 1) 
		{
			if (bmp != null)
			{
				this.bmp = new Bitmap(bmp.bitmapData);
				addChild(this.bmp);
				_halfWidth = width / 2;
				_halfHeight = height / 2;
			}
			position.x = x;
			position.y = y;
			setScale(scale);
		}
		
		public function clone(x:Number = 0, y:Number = 0):GameTexture
		{
			return new GameTexture(bmp, x, y);
		}
		
		public function setScale(scale:Number):void
		{
			this.scaleX = this.scaleY = scale;
		}
		
		public function flipX():void
		{
			bmp.scaleX = -bmp.scaleX;
			if (bmp.scaleX < 0) bmp.x = bmp.width;
			else bmp.x = 0;
		}
		
		public function flipY():void
		{
			bmp.scaleY = -bmp.scaleY;
			if (bmp.scaleY < 0) bmp.y = bmp.height;
			else bmp.y = 0;
		}
		
		public function update():void {} //nothing here, override
	}
}