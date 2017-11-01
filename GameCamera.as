package net.mole.base 
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Vector3D;
	import flash.media.Camera;
	
	/**
	 * ...
	 * @author Mikael Myyrä
	 */
	public class GameCamera extends Sprite 
	{
		private var game:Game;
		private var followedObject:DisplayObject = null;
		private var mouseDrag:Boolean = false;
		private var prevMousePos:Vector3D = new Vector3D();
		
		private var SWF_HALFWIDTH:uint;
		private var SWF_HALFHEIGHT:uint;
		
		private var _zoom:Number = 1;
		public function get zoom():Number { return _zoom; }
		private var zoomPerFrame:Number = 0;
		private var multiplication:Number = 1;
		private var zoomTime:uint = 0;
		private var motion:Vector3D = new Vector3D(0, 0);
		private var moveTime:uint = 0;
		
		public var position:Vector3D = new Vector3D(0, 0);
		private var moved:Boolean = false;
		private var _mousePosition:Vector3D = new Vector3D();
		public function get mousePosition():Vector3D { return _mousePosition; }
		
		private var testShape:Shape = new Shape();
		private var drawingShape:Shape = new Shape();
		
		public var drawTests:Boolean = false;
		
		public function GameCamera(game:Game)
		{
			this.game = game;
			
			SWF_HALFWIDTH = game.SWF_WIDTH / 2;
			SWF_HALFHEIGHT = game.SWF_HEIGHT / 2;
			
			game.addChild(testShape);
			game.addChild(drawingShape);
		}
		
		//TODO gradual zoom for these
		public function zoomOnObject(obj:GameObject):void
		{
			if (obj.width > 0 && obj.height > 0)
			{
				moveTo(obj.position);
				var widthZoom:Number = game.SWF_WIDTH / obj.width;
				var heightZoom:Number = game.SWF_HEIGHT / obj.height;
				_zoom = widthZoom < heightZoom ? widthZoom : heightZoom;
			}
			else trace("Zoom failed - object's width or height is 0");
		}
		
		public function zoomOnBackground(bg:GameTexture):void
		{
			if (bg.width > 0 && bg.height > 0)
			{
				moveTo(bg.position);
				var widthZoom:Number = game.SWF_WIDTH / (bg.halfWidth * 2);
				var heightZoom:Number = game.SWF_HEIGHT / (bg.halfHeight * 2);
				_zoom = widthZoom < heightZoom ? widthZoom : heightZoom;
			}
			else trace("Zoom failed - object's width or height is 0");
		}
		
		public function changeZoom(scale:Number, time:uint = 1):void
		{
			if (scale <= 0)
			{
				trace("Zoom can't be zero or less!");
				return;
			}
			zoomPerFrame = (scale - _zoom) / time;
			zoomTime = time;
		}
		
		public function incrementZoom(diff:Number, time:uint = 1):void
		{
			if (_zoom + diff <= 0)
			{
				trace ("Zoom can't be zero or less!");
				return;
			}
			zoomPerFrame = diff / time;
			zoomTime = time;
		}
		
		public function naturalZoom(scale:Number, time:uint = 1):void
		{
			multiplication = Math.pow(scale, 1.0 / time);
			zoomTime = time;
		}
		
		public function moveTo(target:Vector3D, time:uint = 1):void
		{
			motion.x = ((target.x - position.x) / time);
			motion.y = ((target.y - position.y) / time);
			moveTime = time;
		}
		
		public function move(distance:Vector3D, time:uint = 1):void
		{
			motion.x = distance.x / time;
			motion.y = distance.y / time;
			moveTime = time;
		}
		
		public function startMouseDrag():void
		{
			this.mouseDrag = true;
			prevMousePos = new Vector3D(game.mouseX, game.mouseY);
		}
		
		public function stopMouseDrag():void
		{
			this.mouseDrag = false;
		}
		
		public function update():void
		{
			_mousePosition.x = ((game.mouseX - SWF_HALFWIDTH) / zoom) + this.position.x;
			_mousePosition.y = ((game.mouseY - SWF_HALFHEIGHT) / zoom) + this.position.y;
			
			if (zoomTime > 0)
			{
				if (multiplication != 1) _zoom *= multiplication;
				else _zoom += zoomPerFrame;
				zoomTime--;
				moved = true;
			}
			else 
			{
				zoomPerFrame = 0;
				multiplication = 1;
			}
			
			if (mouseDrag)
			{
				var mouseMotion:Vector3D = new Vector3D(game.mouseX - prevMousePos.x, game.mouseY - prevMousePos.y);
				mouseMotion.scaleBy(1 / _zoom);
				position.decrementBy(mouseMotion);
				prevMousePos = new Vector3D(game.mouseX, game.mouseY);
				moved = true;
			}
			else if (moveTime > 0)
			{
				position.incrementBy(motion);
				moveTime--;
				moved = true;
			}
			else motion = new Vector3D(0, 0);
			
			//Draw stuff
			game.setChildIndex(testShape, game.numChildren - 1);
			testShape.graphics.clear();
			
			for each (var line:Line in game.level.lines)
			{
				if (!line.visible) continue;
				
				testShape.graphics.lineStyle(1, line.color);
				testShape.graphics.moveTo(SWF_HALFWIDTH + ((line.startPoint.x - this.position.x) * zoom), SWF_HALFHEIGHT + ((line.startPoint.y - this.position.y) * zoom));
				testShape.graphics.lineTo(SWF_HALFWIDTH + ((line.endPoint.x - this.position.x) * zoom), SWF_HALFHEIGHT + ((line.endPoint.y - this.position.y) * zoom));
			}
			
			for each (var obj:GameObject in game.level.objects)
			{
				if (this.moved || obj.moved)
				{
					obj.update();
					obj.x = SWF_HALFWIDTH + ((obj.position.x - this.position.x + obj.drawPosition.x) * _zoom);
					obj.y = SWF_HALFHEIGHT + ((obj.position.y - this.position.y + obj.drawPosition.y) * _zoom);
					obj.setScale(_zoom);
					
					if (drawTests) drawHitbox(obj);
					
					obj.moved = false;
				}
			}
			
			if (this.moved)
			{
				for each (var bg:GameTexture in game.level.backgrounds)
				{
					bg.update();
					bg.x = SWF_HALFWIDTH + ((bg.position.x - this.position.x - bg.halfWidth) * _zoom);
					bg.y = SWF_HALFHEIGHT + ((bg.position.y - this.position.y - bg.halfHeight) * _zoom);
					bg.setScale(_zoom);
				}
			}
			
			if (drawTests) drawGrid();
		}
		
		private function drawHitbox(obj:GameObject):void
		{
			testShape.graphics.lineStyle(1, 0xFF0000);
			
			if (obj.hitBox != null)
			{
				if (obj.hitBox.getType() == "polygon")
				{
					var polygon:HBPolygon = obj.hitBox as HBPolygon;
					var prev:uint = polygon.vectors.length - 1;
					for (var i:uint = 0; i < polygon.vectors.length; i++)
					{
						if (i != 0) prev = i - 1;
						testShape.graphics.moveTo(SWF_HALFWIDTH + ((polygon.position.x - this.position.x + polygon.vectors[i].x) * _zoom),
							SWF_HALFHEIGHT + ((polygon.position.y - this.position.y + polygon.vectors[i].y) * _zoom));
						testShape.graphics.lineTo(SWF_HALFWIDTH + ((polygon.position.x - this.position.x + polygon.vectors[prev].x) * _zoom),
							SWF_HALFHEIGHT + ((polygon.position.y - this.position.y + polygon.vectors[prev].y) * _zoom));
					}
				}
				else if (obj.hitBox.getType() == "circle")
				{
					var circle:HBCircle = obj.hitBox as HBCircle;
					testShape.graphics.drawCircle(SWF_HALFWIDTH + ((circle.position.x - this.position.x) * _zoom),
						SWF_HALFHEIGHT + ((circle.position.y - this.position.y) * _zoom), circle.radius * _zoom);
				}
			}
		}
		
		private function drawGrid():void
		{
			testShape.graphics.lineStyle(1, 0x020202, 0.5);
			
			for (var x:int = 0; x <= game.level.grid.gridWidth; x++)
			{
				var xCoord:Number = SWF_HALFWIDTH + (((x * game.level.grid.cellWidth) - this.position.x) * zoom);
				testShape.graphics.moveTo(xCoord, 0)
				testShape.graphics.lineTo(xCoord, game.SWF_HEIGHT);
			}
			
			for (var y:int = 0; y <= game.level.grid.gridHeight; y++)
			{
				var yCoord:Number = SWF_HALFHEIGHT + (((y * game.level.grid.cellHeight) - this.position.y) * zoom);
				testShape.graphics.moveTo(0, yCoord);
				testShape.graphics.lineTo(game.SWF_WIDTH, yCoord);
			}
		}
		
		public function drawCircle(x:Number, y:Number, radius:Number, color:Number = 0x000000, alpha:Number = 1, thickness:Number = 1):void
		{
			game.setChildIndex(drawingShape, game.numChildren - 1);
			drawingShape.graphics.lineStyle(thickness, color, alpha);
			drawingShape.graphics.drawCircle(SWF_HALFWIDTH + ((x - this.position.x) * zoom), SWF_HALFHEIGHT + ((y - this.position.y) * zoom), radius * _zoom);
		}
		
		public function eraseDrawings():void
		{
			drawingShape.graphics.clear();
		}
	}
}