package net.mole.base 
{
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author Mikael Myyrä
	 */
	public class Grid 
	{
		private var level:Level;
		
		private var cells:Vector.<Vector.<GridCell>>;
		
		private var _gridWidth:uint;
		public function get gridWidth():uint { return _gridWidth; }
		private var _gridHeight:uint;
		public function get gridHeight():uint { return _gridHeight; }
		private var _cellHeight:Number;
		public function get cellHeight():Number { return _cellHeight; }
		private var _cellWidth:Number;
		public function get cellWidth():Number { return _cellWidth; }
		
		public function Grid(level:Level, width:uint, height:uint, cellWidth:Number, cellHeight:Number)
		{
			this.level = level;
			_gridWidth = width;
			_gridHeight = height;
			_cellWidth = cellWidth;
			_cellHeight = cellHeight;
			cells = new Vector.<Vector.<GridCell>>(_gridWidth);
			for (var x:uint = 0; x < cells.length; x++)
			{
				cells[x] = new Vector.<GridCell>();
				for (var y:uint = 0; y < gridHeight; y++)
				{
					cells[x][y] = new GridCell();
				}
			}
		}
		
		public function getObjectsToTest(obj:GameObject):Vector.<int>
		{
			if (!obj.collidable) return new Vector.<int>();
			
			var objsToTest:Vector.<int> = new Vector.<int>();
			for (var x:int = obj.gridCell.x - 1; x <= obj.gridCell.x + 1; x++)
			{
				for (var y:int = obj.gridCell.y - 1; y <= obj.gridCell.y + 1; y++)
				{
					if (x >= 0 && x < _gridWidth && y >= 0 && y < _gridHeight)
					{
						for each (var cellObj:int in cells[x][y].objects)
						if (cellObj != obj.ID && level.getObjectByID(cellObj).collidable) objsToTest.push(cellObj);
					}
				}
			}
			return objsToTest;
		}
		
		public function getLinesToTest(obj:GameObject):Vector.<Line>
		{
			if (!obj.collidable) return new Vector.<Line>();
			
			var linesToTest:Vector.<Line> = new Vector.<Line>();
			for (var x:int = obj.gridCell.x - 1; x <= obj.gridCell.x + 1; x++)
			{
				for (var y:int = obj.gridCell.y - 1; y <= obj.gridCell.y + 1; y++)
				{
					if (x >= 0 && x < _gridWidth && y >= 0 && y < _gridHeight)
					{
						for each (var line:Line in cells[x][y].lines)
							if (linesToTest.indexOf(line) < 0) linesToTest.push(line);
					}
				}
			}
			return linesToTest;
		}
		
		public function removeObject(obj:GameObject):void
		{
			if (isInBounds(obj)) cells[obj.gridCell.x][obj.gridCell.y].removeObject(obj.ID);
		}
		
		public function addObject(obj:GameObject):void
		{
			obj.gridCell = new Vector3D(Math.floor(obj.position.x / _cellWidth), Math.floor(obj.position.y / _cellHeight));
			
			if (isInBounds(obj)) cells[obj.gridCell.x][obj.gridCell.y].addObject(obj.ID);
		}
		
		public function addLine(line:Line):void
		{
			var cellX:int = Math.floor(line.startPoint.x / _cellWidth);
			var cellY:int = Math.floor(line.startPoint.y / _cellHeight);
			var endX:int = Math.floor(line.endPoint.x / _cellWidth);
			var endY:int = Math.floor(line.endPoint.y / _cellHeight);
			if (cellX < 0 || cellX >= _gridWidth || cellY < 0 || cellY >= _gridHeight || endX < 0 || endX >= _gridWidth || endY < 0 || endY >= _gridHeight)
			{
				trace("Line is (partially) out of grid - can't add to collision grid");
				return;
			}
			
			var direction:Vector3D = line.asVector.clone();
			direction.normalize();
			var dirX:int = direction.x < 0 ? -1 : 1;
			var dirY:int = direction.y < 0 ? -1 : 1;
			var tMaxX:Number;
			var tMaxY:Number;
			var tDeltaX:Number;
			var tDeltaY:Number;
			var horizontal:Boolean = false;
			
			if (direction.x != 0)
			{
				tMaxX = dirX == 1 ? Math.abs(((cellX + 1) * _cellWidth - line.startPoint.x) / direction.x) : Math.abs((line.startPoint.x - cellX * _cellWidth) / direction.x);
				tDeltaX = Math.abs(_cellWidth / direction.x);
			}
			if (direction.y == 0)
			{
				horizontal = true;
			}
			else
			{
				tMaxY = dirY == 1 ? Math.abs(((cellY + 1) * _cellHeight - line.startPoint.y) / direction.y) : Math.abs((line.startPoint.y - cellY * _cellHeight) / direction.y);
				tDeltaY = Math.abs(_cellHeight / direction.y);
			}
			
			while (cellX != endX || cellY != endY)
			{
				cells[cellX][cellY].addLine(line);
				
				if (horizontal || tMaxX < tMaxY)
				{
					tMaxX += tDeltaX;
					cellX += dirX;
				}
				else
				{
					tMaxY += tDeltaY;
					cellY += dirY;
				}
			}
			cells[endX][endY].addLine(line);
		}
		
		public function isInBounds(obj:GameObject):Boolean
		{
			return obj.gridCell.x >= 0 && obj.gridCell.x < _gridWidth && obj.gridCell.y >= 0 && obj.gridCell.y < _gridHeight;
		}
	}
}