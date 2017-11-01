package net.mole.base 
{
	import flash.display.Shape;
	import flash.geom.Vector3D;
	import net.mole.game.Main;
	/**
	 * ...
	 * @author Mikael Myyrä
	 */
	public class GamePhysics 
	{
		private var game:Game;
		
		public var usePhysics:Boolean = true;
		
		private var movedObjects:Vector.<GameObject> = new Vector.<GameObject>();
		private var pairsTested:Vector.<Vector3D> = new Vector.<Vector3D>();
		
		private const MAX_SPEED:Number = 50;
		
		public function GamePhysics(game:Game)
		{
			this.game = game;
		}
		
		//TODO friction, resting contact forces
		
		public function update():void
		{
			if (usePhysics)
			{
				switch (game.level.type)
				{
					case Level.TYPE_SIDESCROLLING: applyGravity(); break;
					case Level.TYPE_TOPDOWN: applyFriction(); break;
					default: trace("Invalid level type: " + game.level.type); break;
				}
			}
			movedObjects = new Vector.<GameObject>();
			moveAllObjects();
			testCollisions();
		}
		
		private function applyGravity():void
		{
			for each (var obj:GameObject in game.level.objects)
			{
				if (obj.hasGravity && obj.usePhysics && obj.movable) applyForce(obj, new Vector3D(0, game.level.info["gravity"] * obj.mass), new Vector3D(0, 0));
				if (obj.velocity.length > MAX_SPEED) obj.velocity.scaleBy(MAX_SPEED / obj.velocity.length);
			}
		}
		
		private function applyFriction():void
		{
			for each (var obj:GameObject in game.level.objects)
			{
				if (obj.velocity.length > 0 && obj.usePhysics)
				{
					var totalFriction:Number = game.level.info["friction"] * obj.friction;
					if (totalFriction != 0)
					{
						obj.velocity.scaleBy(1 - totalFriction);
						obj.angularVelocity *= 1 - totalFriction;
					}
				}
			}
		}
		
		private function moveAllObjects():void
		{
			for each (var obj:GameObject in game.level.objects)
			{
				if (obj.velocity.length != 0)
				{
					moveObject(obj, obj.velocity);
					obj.moved = true;
				}
				
				if (obj.angularVelocity != 0)
				{
					obj.rotate(obj.angularVelocity);
					obj.moved = true;
				}
				
				if (obj.moved) movedObjects.push(obj);
			}
		}
		
		private function moveObject(obj:GameObject, distance:Vector3D):void
		{
			if (obj.collidable)
			{
				game.level.grid.removeObject(obj);
				obj.position.incrementBy(distance);
				game.level.grid.addObject(obj);
			}
			else
			{
				obj.position.incrementBy(distance);
			}
		}
		
		private function testCollisions():void
		{
			var info:CollisionInfo;
			
			for each (var obj1:GameObject in movedObjects)
			{
				var objsToTest:Vector.<int> = game.level.grid.getObjectsToTest(obj1);
				
				var linesToTest:Vector.<Line> = game.level.grid.getLinesToTest(obj1);
				
				for each (var line:Line in linesToTest)
				{
					if (obj1.hitBox.getType() == "circle")
					{
						info = Collision.testCircleLine(obj1.hitBox as HBCircle, line);
					}
					else if (obj1.hitBox.getType() == "polygon")
					{
						info = Collision.testPolyLine(obj1.hitBox as HBPolygon, line);
					}
					
					if (info != null)
					{
						resolvePenetration(obj1, info);
						if (usePhysics) applyLineCollision(obj1, line, info);
					}
				}
				
				for each (var id:int in objsToTest)
				{
					var pair:Vector3D = new Vector3D(obj1.ID, id);
					var reverse:Vector3D = new Vector3D(id, obj1.ID);
					
					if (pairsTested.indexOf(pair) < 0 && pairsTested.indexOf(reverse) < 0)
					{
						pairsTested.push(pair);
					}
					else continue;
					
					var obj2:GameObject = game.level.getObjectByID(id);
					
					if (obj1.hitBox.getType() == "circle")
					{
						if (obj2.hitBox.getType() == "circle") //circle-circle test
						{
							info = Collision.testCircleCircle(obj1.hitBox as HBCircle, obj2.hitBox as HBCircle);
						}
						else if (obj2.hitBox.getType() == "polygon") //circle-polygon test
						{
							info = Collision.testCirclePoly(obj1.hitBox as HBCircle, obj2.hitBox as HBPolygon);
						}
					}
					else if (obj1.hitBox.getType() == "polygon")
					{
						if (obj2.hitBox.getType() == "circle") //circle-polygon test
						{
							info = Collision.testPolyCircle(obj1.hitBox as HBPolygon, obj2.hitBox as HBCircle);
						}
						else if (obj2.hitBox.getType() == "polygon") //polygon-polygon test
						{
							info = Collision.testPolyPoly(obj1.hitBox as HBPolygon, obj2.hitBox as HBPolygon);
						}
					}
					
					if (info != null)
					{
						resolvePenetration(obj1, info);
						if (usePhysics) applyCollision(obj1, obj2, info);
						obj1.onCollision(obj2);
						obj2.onCollision(obj1);
					}
				}
			}
		}
		
		
		private function resolvePenetration(obj:GameObject, info:CollisionInfo):void
		{
			if (obj.collidable) moveObject(obj, info.penetration);
		}
		
		private function applyCollision(obj1:GameObject, obj2:GameObject, info:CollisionInfo):void
		{
			var obj1ToP:Vector3D = info.forcePosition.subtract(obj1.position);
			var obj2ToP:Vector3D = info.forcePosition.subtract(obj2.position);
			
			var penAxis:Vector3D = info.penetration.clone();
			penAxis.normalize();
			
			var tanVel1:Vector3D = new Vector3D(-obj1ToP.y, obj1ToP.x);
			var tanVel2:Vector3D = new Vector3D(-obj2ToP.y, obj2ToP.x);
			tanVel1.normalize();
			tanVel2.normalize();
			tanVel1.scaleBy((obj1.angularVelocity * (Math.PI / 180)) * obj1ToP.length);
			tanVel2.scaleBy((obj2.angularVelocity * (Math.PI / 180)) * obj2ToP.length);
			
			var pointVel1:Vector3D = tanVel1.add(obj1.velocity);
			var pointVel2:Vector3D = tanVel2.add(obj2.velocity);
			
			var relVel:Vector3D = pointVel1.subtract(pointVel2);
			
			var elasticity:Number = obj1.elasticity * obj2.elasticity;
			
			var impulse:Vector3D = penAxis.clone();
			var normalVel:Number = relVel.dotProduct(penAxis);
			var divider:Number;
			
			var movableObj:GameObject
			var toPoint:Vector3D;
			var pointVel:Vector3D;
			
			if (obj1.movable && obj1.usePhysics && obj2.movable && obj2.usePhysics)
			{
				normalVel *= ( -1 - elasticity);
				
				divider = (1 / obj1.mass) + (1 / obj2.mass) + (obj1ToP.crossProduct(penAxis).lengthSquared / obj1.momentOfInertia) + 
						(obj2ToP.crossProduct(penAxis).lengthSquared / obj2.momentOfInertia);
				impulse.scaleBy(normalVel / divider);
				
				obj1.velocity.x += impulse.x / obj1.mass;
				obj1.velocity.y += impulse.y / obj1.mass;
				obj2.velocity.x -= impulse.x / obj2.mass;
				obj2.velocity.y -= impulse.y / obj2.mass;
				
				obj1.angularVelocity += (180 / Math.PI) * (impulse.y * obj1ToP.x - impulse.x * obj1ToP.y) / obj1.momentOfInertia;
				obj2.angularVelocity -= (180 / Math.PI) * (impulse.y * obj2ToP.x - impulse.x * obj2ToP.y) / obj2.momentOfInertia;
				
				applyCollisionFriction(obj1, pointVel1, obj1.friction * obj2.friction, new Vector3D(-impulse.x, -impulse.y));
				applyCollisionFriction(obj2, pointVel2, obj1.friction * obj2.friction, impulse);
			}
			else 
			{
				if (obj1.movable && obj1.usePhysics)
				{
					movableObj = obj1;
					toPoint = obj1ToP;
					pointVel = pointVel1;
				}
				else if (obj2.movable && obj2.usePhysics)
				{
					movableObj = obj2;
					toPoint = obj2ToP;
					impulse.negate();
					pointVel = pointVel2;
				}
				else return;
				
				normalVel *= ( -1 - elasticity);
				divider = (1 / movableObj.mass) + (toPoint.crossProduct(penAxis).lengthSquared / movableObj.momentOfInertia);
				impulse.scaleBy(normalVel / divider);
			
				movableObj.velocity.x += impulse.x / movableObj.mass;
				movableObj.velocity.y += impulse.y / movableObj.mass;
				movableObj.angularVelocity += (180 / Math.PI) * (impulse.y * toPoint.x - impulse.x * toPoint.y) / movableObj.momentOfInertia;
				
				applyCollisionFriction(movableObj, pointVel, obj1.friction * obj2.friction, new Vector3D(-impulse.x, -impulse.y));
			}
		}
		
		private function applyLineCollision(obj:GameObject, line:Line, info:CollisionInfo):void
		{
			var objToP:Vector3D = info.forcePosition.subtract(obj.position);
			var tanVel:Vector3D = new Vector3D(-objToP.y, objToP.x);
			tanVel.normalize();
			tanVel.scaleBy(obj.angularVelocity * (Math.PI / 180) * objToP.length);
			var pointVel:Vector3D = tanVel.add(obj.velocity);
			
			var penAxis:Vector3D = info.penetration.clone();
			penAxis.normalize();
			var elasticity:Number = line.elasticity * obj.elasticity;
			
			var impulse:Vector3D = penAxis.clone();
			var normalVel:Number = pointVel.dotProduct(penAxis);
			var divider:Number;
			
			normalVel *= ( -1 - elasticity);
			divider = (1 / obj.mass) + (objToP.crossProduct(penAxis).lengthSquared / obj.momentOfInertia);
			impulse.scaleBy(normalVel / divider);
			
			obj.velocity.x += impulse.x / obj.mass;
			obj.velocity.y += impulse.y / obj.mass;
			obj.angularVelocity += (180 / Math.PI) * (impulse.y * objToP.x - impulse.x * objToP.y) / obj.momentOfInertia;
			
			var before:Number = obj.angularVelocity;
			applyCollisionFriction(obj, pointVel, obj.friction * line.friction, new Vector3D( -impulse.x, -impulse.y));
		}
		
		private function applyCollisionFriction(obj:GameObject, pointVel:Vector3D, friction:Number, direction:Vector3D):void
		{
			var surface:Vector3D = new Vector3D(-direction.y, direction.x);
			var force:Vector3D = VectorHelper.projectVector(obj.velocity, surface);
			force.negate();
			force.scaleBy(friction * obj.mass);
			var position:Vector3D;
			
			if (obj.hitBox.getType() == "polygon") position = (obj.hitBox as HBPolygon).getFarthestPoint(direction);
			else
			{
				position = direction.clone();
				position.normalize();
				position.scaleBy(obj.hitBox.radius);
			}
			
			applyForce(obj, force, position);
		}
		
		public function applyForce(obj:GameObject, force:Vector3D, distFromObj:Vector3D):void
		{
			obj.velocity.x += force.x / obj.mass;
			obj.velocity.y += force.y / obj.mass;
			obj.angularVelocity += (180 / Math.PI) * (force.y * distFromObj.x - force.x * distFromObj.y) / obj.momentOfInertia;
		}
	}
}