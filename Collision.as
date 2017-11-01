package net.mole.base 
{
	import flash.geom.Vector3D;
	import flash.media.Video;
	import net.mole.game.Main;
	/**
	 * ...
	 * @author Mikael Myyrä
	 */
	public class Collision 
	{
		
		public function Collision() 
		{
			
		}
		
		public static function testCircleCircle(circle1:HBCircle, circle2:HBCircle):CollisionInfo
		{
			var info:CollisionInfo = new CollisionInfo();
			
			info.distance = circle2.position.subtract(circle1.position);
			
			var penetration:Number = circle1.radius + circle2.radius - info.distance.length;
			
			if (penetration > 0) info.penetration = new Vector3D(-penetration * (info.distance.x / info.distance.length), -penetration * (info.distance.y / info.distance.length));
			else return null;
			
			info.forcePosition = info.penetration.clone();
			info.forcePosition.normalize();
			info.forcePosition.scaleBy( -circle1.radius);
			info.forcePosition.incrementBy(circle1.position);
			info.forcePosition.incrementBy(info.penetration);
			
			return info;
		}
		
		public static function testCirclePoly(circle:HBCircle, polygon:HBPolygon):CollisionInfo
		{
			var info:CollisionInfo = doTestCirclePoly(circle, polygon);
			
			if (info == null) return null;
			
			info.forcePosition = info.penetration.clone();
			info.forcePosition.normalize();
			info.forcePosition.scaleBy( -circle.radius);
			info.forcePosition.incrementBy(circle.position);
			info.forcePosition.incrementBy(info.penetration);
			
			return info;
		}
		
		public static function testPolyCircle(polygon:HBPolygon, circle:HBCircle):CollisionInfo
		{
			var info:CollisionInfo = doTestCirclePoly(circle, polygon);
			
			if (info == null) return null;
			
			info.distance.negate();
			info.penetration.negate();
			
			info.forcePosition = info.penetration.clone();
			info.forcePosition.normalize();
			info.forcePosition.scaleBy(circle.radius);
			info.forcePosition.incrementBy(circle.position);
			
			return info;
		}
		
		public static function doTestCirclePoly(circle:HBCircle, polygon:HBPolygon):CollisionInfo
		{
			var info:CollisionInfo = new CollisionInfo();
			info.penetration = new Vector3D(1000);
			
			info.distance = polygon.position.subtract(circle.position);
			
			var penDepth:Number;
			
			//test each of the polygon's axes
			for (var i1:int = 0; i1 < polygon.normals.length; i1++)
			{
				var flipAxis:Boolean = polygon.normals[i1].dotProduct(info.distance) > 0;
				var distOnAxis:Number = VectorHelper.projectVector(info.distance, polygon.normals[i1]).length;
				
				if (!flipAxis) penDepth = polygon.halfWidths[i1] + circle.radius - distOnAxis;
				else penDepth = polygon.reverseHalfWidths[i1] + circle.radius - distOnAxis;
				
				if (penDepth < 0)
				{
					return null;
				}
				else if (penDepth < info.penetration.length)
				{
					info.penetration = polygon.normals[i1].clone();
					info.penetration.scaleBy(penDepth);
					if (flipAxis) info.penetration.negate();
				}
			}
			
			//clumsy way to get closest point
			var axis:Vector3D = info.distance.add(polygon.vectors[0]);
			for (var i2:int = 1; i2 < polygon.vectors.length; i2++)
			{
				var next:Vector3D = info.distance.add(polygon.vectors[i2]);
				if (next.length < axis.length) axis = next.clone();
			}
			axis.normalize();
			axis.negate();
			
			distOnAxis = VectorHelper.projectVector(info.distance, axis).length;
			penDepth = polygon.getHalfWidth(axis) + circle.radius - distOnAxis;
			if (penDepth < 0)
			{
				return null;
			}
			else if (penDepth < info.penetration.length)
			{
				axis.scaleBy(penDepth);
				info.penetration = axis;
			}
			
			return info;
		}
		
		public static function testPolyPoly(polygon1:HBPolygon, polygon2:HBPolygon):CollisionInfo
		{
			var info:CollisionInfo = new CollisionInfo();
			
			info.distance = polygon1.position.subtract(polygon2.position);
			
			var pen2:Vector3D = checkObjAxes(polygon1, polygon2, info.distance);
			if (pen2 == null) return null;
			info.distance.negate();
			var pen1:Vector3D = checkObjAxes(polygon2, polygon1, info.distance);
			if (pen1 == null) return null;
			
			var fp1:Vector3D = polygon1.getFarthestPoint(pen2);
			var fp2:Vector3D = polygon2.getFarthestPoint(pen1);
			
			if (fp1.w != 0 && fp2.w != 0)
			{
				info.penetration = pen1;
				
				var points:Vector.<Vector3D> = new Vector.<Vector3D>(4);
				points[0] = new Vector3D(fp1.x, fp1.y).add(polygon1.position).add(pen1);
				points[1] = new Vector3D(fp1.z, fp1.w).add(polygon1.position).add(pen1);
				points[2] = new Vector3D(fp2.x, fp2.y).add(polygon2.position);
				points[3] = new Vector3D(fp2.z, fp2.w).add(polygon2.position);
				
				if (Math.abs((points[0].x - points[1].x) / (points[0].y - points[1].y)) > 1) points.sort(function fx(par1:Vector3D, par2:Vector3D):Number { return par1.x < par2.x ? -1 : 1 } );
				else points.sort(function fy(par1:Vector3D, par2:Vector3D):Number { return par1.y > par2.y ? -1 : 1 } );
				
				info.forcePosition = points[2].subtract(points[1]);
				info.forcePosition.scaleBy(0.5);
				info.forcePosition.incrementBy(points[1]);
			}
			else if (pen2.length < pen1.length)
			{
				pen2.negate();
				info.penetration = pen2;
				info.forcePosition = polygon2.getFarthestPoint(pen2);
				info.forcePosition.incrementBy(polygon2.position);
			}
			else
			{
				info.penetration = pen1;
				info.forcePosition = polygon1.getFarthestPoint(new Vector3D(-pen1.x, -pen1.y));
				info.forcePosition.incrementBy(info.penetration);
				info.forcePosition.incrementBy(polygon1.position);
			}
			return info;
		}
		
		private static function checkObjAxes(axisBox:HBPolygon, testBox:HBPolygon, distance:Vector3D):Vector3D
		{
			var flipAxis:Boolean;
			var distOnAxis:Number;
			
			var pen:Vector3D = new Vector3D(1000);
			var penDepth:Number;
			
			for (var i:int = 0; i < axisBox.normals.length; i++)
			{
				flipAxis = axisBox.normals[i].dotProduct(distance) > 0;
				distOnAxis = Math.abs(axisBox.normals[i].dotProduct(distance));
				
				if (!flipAxis) penDepth = axisBox.halfWidths[i] + testBox.getHalfWidth(new Vector3D(-axisBox.normals[i].x, -axisBox.normals[i].y)) - distOnAxis;
				else penDepth = axisBox.reverseHalfWidths[i] + testBox.getHalfWidth(axisBox.normals[i]) - distOnAxis;
				
				if (penDepth < 0)
				{
					return null;
				}
				else if (penDepth < pen.length)
				{
					pen = axisBox.normals[i].clone();
					pen.scaleBy(penDepth);
					if (flipAxis) pen.negate();
				}
			}
			return pen;
		}
		
		public static function testCircleLine(circle:HBCircle, line:Line):CollisionInfo
		{
			var info:CollisionInfo = new CollisionInfo();
			
			var toSP:Vector3D = line.startPoint.subtract(circle.position);
			info.distance = toSP.subtract(VectorHelper.projectVector(toSP, line.asVector));
			
			var penDepth:Number = circle.radius - info.distance.length;
			
			if (penDepth < 0)
			{
				return null;
			}
			else
			{
				info.penetration = info.distance.clone();
				info.penetration.negate();
				info.penetration.normalize();
				info.penetration.scaleBy(penDepth);
			}
			
			//See if collides with one of the line's ends
			var axis:Vector3D;
			if (line.startPoint.subtract(circle.position).length > line.length)
				axis = line.endPoint.subtract(circle.position);
			else if (line.endPoint.subtract(circle.position).length > line.length)
				axis = line.startPoint.subtract(circle.position);
			
			if (axis != null)
			{
				penDepth = circle.radius - axis.length;
				if (penDepth < 0)
				{
					return null;
				}
				else if (penDepth < info.penetration.length)
				{
					info.distance = axis.clone();
					info.penetration = axis.clone();
					info.penetration.normalize();
					info.penetration.scaleBy( -penDepth);
					info.forcePosition = circle.position.add(axis);
				}
			}
			else
			{
				info.forcePosition = info.distance.clone();
				info.forcePosition.normalize();
				info.forcePosition.scaleBy(circle.radius);
				info.forcePosition.incrementBy(info.penetration);
				info.forcePosition.incrementBy(circle.position);
			}
			
			return info;
		}
		
		public static function testPolyLine(polygon:HBPolygon, line:Line):CollisionInfo
		{
			var info:CollisionInfo = new CollisionInfo();
			
			var toSP:Vector3D = line.startPoint.subtract(polygon.position);
			info.distance = toSP.subtract(VectorHelper.projectVector(toSP, line.asVector));
			
			var penDepth:Number = polygon.getHalfWidth(info.distance) - info.distance.length;
			
			if (penDepth < 0)
			{
				return null;
			}
			else
			{
				info.penetration = info.distance.clone();
				info.penetration.normalize();
				info.penetration.scaleBy(-penDepth);
			}
			
			//See if collides with one of the line's ends
			var distToCenter:Vector3D = line.center.subtract(polygon.position);
			var touchedEnd:Vector3D;
			
			for (var i:int = 0; i < polygon.normals.length; i++)
			{
				var flipAxis:Boolean = polygon.normals[i].dotProduct(distToCenter) < 0;
				var distOnAxis:Number = Math.abs(distToCenter.dotProduct(polygon.normals[i]));
				
				if (!flipAxis) penDepth = polygon.halfWidths[i] + (Math.abs(polygon.normals[i].dotProduct(line.asVector) / 2)) - distOnAxis;
				else penDepth = polygon.reverseHalfWidths[i] + (Math.abs(polygon.normals[i].dotProduct(line.asVector) / 2)) - distOnAxis;
				
				if (penDepth < 0)
				{
					return null;
				}
				else if (penDepth < info.penetration.length)
				{
					info.penetration = flipAxis ? new Vector3D(-polygon.normals[i].x, -polygon.normals[i].y) : polygon.normals[i].clone();
					info.penetration.normalize();
					info.penetration.scaleBy(-penDepth);
					
					touchedEnd = line.asVector.dotProduct(distToCenter) > 0 ? line.startPoint : line.endPoint;
					info.distance = touchedEnd.subtract(polygon.position);
				}
			}
			
			info.forcePosition = polygon.getFarthestPoint(info.distance);
			info.forcePosition.incrementBy(info.penetration);
			info.forcePosition.incrementBy(polygon.position);
			
			if (info.forcePosition.w != 0)
			{
				var p1:Vector3D = new Vector3D(info.forcePosition.x, info.forcePosition.y);
				var p2:Vector3D = new Vector3D(info.forcePosition.z, info.forcePosition.w);
				if (touchedEnd == null)
				{
					var p1top2:Vector3D = p2.subtract(p1);
					p1top2.scaleBy(0.5);
					info.forcePosition = p1.add(p1top2);
				}
				else
				{
					var closerPoint:Vector3D = line.center.subtract(p1).length < line.center.subtract(p2).length ? p1 : p2;
					var CPToEnd:Vector3D = closerPoint.subtract(touchedEnd);
					CPToEnd.scaleBy(0.5);
					info.forcePosition = closerPoint.add(CPToEnd);
				}
			}
			else if (touchedEnd != null)
			{
				info.forcePosition = touchedEnd;
			}
			
			return info;
		}
	}
}