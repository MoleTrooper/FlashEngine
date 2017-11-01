package net.mole.base 
{
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author Mikael Myyrä
	 */
	public class HBPolygon extends HitBox
	{
		private var _rotation:Number = 0;
		public function get rotation():Number { return _rotation; }
		//Vectors relative to the center
		private var _vectors:Vector.<Vector3D> = new Vector.<Vector3D>();
		public function get vectors():Vector.<Vector3D> { return _vectors; }
		//The potential separating axes of the shape, represented as unit vectors
		private var _normals:Vector.<Vector3D> = new Vector.<Vector3D>();
		public function get normals():Vector.<Vector3D> { return _normals; }
		private var _halfWidths:Vector.<Number> = new Vector.<Number>();
		public function get halfWidths():Vector.<Number> { return _halfWidths; }
		private var _reverseHalfWidths:Vector.<Number> = new Vector.<Number>();
		public function get reverseHalfWidths():Vector.<Number> { return _reverseHalfWidths; }
		
		public function HBPolygon(vecs:Vector.<Vector3D>, x:Number = 0, y:Number = 0)
		{
			if (vecs.length < 3)
			{
				throw new Error("Invalid polygon - three or more vertices required");
			}
			else
			{
				position = new Vector3D(x, y);
				_vectors = vecs;
				calculateNormals();
				center();
				calculateRadius();
			}
		}
		
		public override function getType():String
		{
			return "polygon";
		}
		
		public function clone():HBPolygon
		{
			var newVecs:Vector.<Vector3D> = new Vector.<Vector3D>();
			for (var i:int = 0; i < _vectors.length; i++)
			{
				newVecs[i] = _vectors[i].clone();
			}
			return new HBPolygon(newVecs, position.x, position.y);
		}
		
		private function calculateRadius():void
		{
			var longest:Number = 0;
			for (var i:int = 0; i < _vectors.length; i++)
			{
				if (_vectors[i].length > longest) longest = _vectors[i].length;
			}
			_radius = longest;
		}
		
		public function getHalfWidth(axis:Vector3D):Number
		{
			var normAxis:Vector3D = axis.clone();
			if (normAxis.length != 1) normAxis.normalize();
			
			var i:int = _vectors.length - 1;
			
			var prev:Number = _vectors[i].dotProduct(normAxis);
			var current:Number = _vectors[0].dotProduct(normAxis);
			
			if (prev > current)
			{
				while (prev > current)
				{
					i--;
					current = prev;
					prev = _vectors[i].dotProduct(normAxis);
				}
			}
			else
			{
				i = 1;
				var next:Number = _vectors[i].dotProduct(normAxis);
				while (next > current)
				{
					i++;
					current = next;
					next = _vectors[i].dotProduct(normAxis);
				}
			}
			
			return current;
		}
		
		public function getFarthestPoint(axis:Vector3D):Vector3D
		{
			var normAxis:Vector3D = axis.clone();
			if (normAxis.length != 1) normAxis.normalize();
			
			var i:int = _vectors.length - 1;
			
			var prev:Number = _vectors[i].dotProduct(normAxis);
			var current:Number = _vectors[0].dotProduct(normAxis);
			
			if (prev == current)
			{
				if (prev > 0)
				{
					return new Vector3D(_vectors[0].x, _vectors[0].y, _vectors[i].x, _vectors[i].y);
				}
				
				i--;
				current = prev;
				prev = _vectors[i].dotProduct(normAxis);
			}
			
			if (prev > current)
			{
				while (prev > current)
				{
					i--;
					current = prev;
					prev = _vectors[i].dotProduct(normAxis);
				}
				return prev == current ? new Vector3D(_vectors[i + 1].x, _vectors[i + 1].y, _vectors[i].x, _vectors[i].y) : _vectors[i + 1].clone();
			}
			else
			{
				i = 1;
				var next:Number = _vectors[i].dotProduct(normAxis);
				while (next > current)
				{
					i++;
					current = next;
					next = _vectors[i].dotProduct(normAxis);
				}
				return next == current ? new Vector3D(_vectors[i - 1].x, _vectors[i - 1].y, _vectors[i].x, _vectors[i].y) : _vectors[i - 1].clone();
			}
		}
		
		private function calculateNormals():void
		{
			_normals = new Vector.<Vector3D>();
			_halfWidths = new Vector.<Number>();
			_reverseHalfWidths = new Vector.<Number>();
			
			var absoluteVecs:Vector.<Vector3D> = new Vector.<Vector3D>();
			for (var i:uint = 0; i < _vectors.length - 1; i++) { absoluteVecs.push(_vectors[i + 1].subtract(_vectors[i])); }
			absoluteVecs.push(_vectors[0].subtract(_vectors[_vectors.length - 1]));
			
			for (var i1:uint = 0; i1 < absoluteVecs.length; i1++)
			{
				var normal:Vector3D = new Vector3D( -absoluteVecs[i1].y, absoluteVecs[i1].x);
				normal.normalize();
				var exists:Boolean = false;
				
				for (var i2:uint = 0; i2 < _normals.length; i2++)
				{
					if (VectorHelper.parallel(_normals[i2], normal))
					{
						exists = true;
						break;
					}
				}
				if (!exists)
				{
					_normals.push(normal);
					_halfWidths.push(getHalfWidth(normal));
					_reverseHalfWidths.push(getHalfWidth(new Vector3D( -normal.x, -normal.y)));
				}
			}
		}
		
		public override function rotate(angle:Number):void
		{
			for each (var norm:Vector3D in _normals) VectorHelper.rotateVector(norm, angle);
			
			for each (var vec:Vector3D in _vectors) VectorHelper.rotateVector(vec, angle);
		}
		
		public override function scale(width:Number, height:Number):HitBox
		{
			var box:HBPolygon = normalize(this);
			for each(var vec1:Vector3D in box._vectors)
			{
				vec1.x *= width;
				vec1.y *= height;
			}
			box.calculateNormals();
			box.calculateRadius();
			return box;
		}
		
		private function normalize(box:HBPolygon):HBPolygon
		{
			var newBox:HBPolygon = box.clone();
			
			var lowestX:Number = 0;
			var highestX:Number = 0;
			var lowestY:Number = 0;
			var highestY:Number = 0;
			
			for each (var vec:Vector3D in newBox._vectors)
			{
				if (vec.x - vec.w < lowestX) lowestX = vec.x - vec.w;
				if (vec.x + vec.w > highestX) highestX = vec.x + vec.w;
				if (vec.y - vec.w < lowestY) lowestY = vec.y - vec.w;
				if (vec.y + vec.w > highestY) highestY = vec.y + vec.w;
			}
			
			var width:Number = highestX - lowestX;
			var height:Number = highestY - lowestY;
			
			for each (var vec1:Vector3D in newBox._vectors)
			{
				vec1.x *= 1 / width;
				vec1.y *= 1 / height;
			}
			
			return newBox;
		}
		
		private function center():void
		{
			var area:Number = 0;
			var cx:Number = 0;
			var cy:Number = 0;
			var next:uint;
			
			for (var i:uint = 0; i < _vectors.length; i++)
			{
				next = i == _vectors.length - 1 ? 0 : i + 1;
				var thing:Number = _vectors[i].x * _vectors[next].y - _vectors[next].x * _vectors[i].y;
				area += thing;
				
				cx += thing * (_vectors[i].x + _vectors[next].x);
				cy += thing * (_vectors[i].y + _vectors[next].y);
			}
			area /= 2;
			cx /= 6 * area;
			cy /= 6 * area;
			
			var centroid:Vector3D = new Vector3D(cx, cy);
			
			for each (var vec:Vector3D in _vectors)
			{
				vec.decrementBy(centroid);
			}
		}
	}
}