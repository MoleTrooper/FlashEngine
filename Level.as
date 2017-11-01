package net.mole.base 
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author Mikael Myyrä
	 */
	public class Level extends Sprite
	{
		public var game:Game;
		
		public var grid:Grid;
		
		private var _objects:Vector.<GameObject> = new Vector.<GameObject>();
		public function get objects():Vector.<GameObject> { return _objects; }
		private var _lines:Vector.<Line> = new Vector.<Line>();
		public function get lines():Vector.<Line> { return _lines; }
		private var _backgrounds:Vector.<GameTexture> = new Vector.<GameTexture>();
		public function get backgrounds():Vector.<GameTexture> { return _backgrounds; }
		private var _tiles:Vector.<GameObject> = new Vector.<GameObject>();
		public function get tiles():Vector.<GameObject> { return _tiles; }
		
		private var allObjects:Object = new Object();
		
		public var info:Object = new Object();
		public var defaultInfo:Object = new Object();
		
		public var type:int = 0;
		public static const TYPE_SIDESCROLLING:int = 0;
		public static const TYPE_TOPDOWN:int = 1;
		
		public function Level(game:Game)
		{
			this.game = game;
			grid = new Grid(this, 0, 0, 0, 0);
			defaultInfo["gravity"] = 0.8;
			defaultInfo["friction"] = 0.05;
			defaultInfo["wind"] = 0.0;
			defaultInfo["hasBorders"] = true;
			defaultInfo["drawBorders"] = true;
			defaultInfo["borderColor"] = 0x000000;
			resetToDefaults();
		}
		
		public function addObject(obj:GameObject):int
		{
			obj.ID = _objects.push(obj) - 1;
			addChild(_objects[obj.ID]);
			grid.addObject(_objects[obj.ID]);
			
			return obj.ID;
		}
		
		public function addLine(line:Line):void
		{
			_lines.push(line);
			grid.addLine(line);
		}
		
		public function addBackground(bg:GameTexture):void
		{
			_backgrounds.push(bg);
			addChild(bg);
		}
		
		public function load(levelData:String):void
		{
			game.onLoadLevel();
			
			clear();
			
			var data:Array = levelData.split("$");
			
			if (data.length != 5)
				game.onLoadError("Invalid level data. Format: grid dimensions$backgrounds$tiles$objects and lines$info");
			else
			{
				var objData:Array = data[0].split(",");
				
				if (objData.length != 4)
					game.onLoadError("Invalid grid dimensions: " + data[0]);
				else
				{
					grid = new Grid(this, objData[0], objData[1], objData[2], objData[3]);
					
					for each (var bg:String in data[1].split("#"))
					{
						objData = bg.split(",");
						if (allObjects[objData[0]] == null)
						{
							trace("Invalid background key: " + objData[0] + ". Skipping entity.");
							continue;
						}
						if (objData.length == 3)
						{
							var newBG:GameTexture = (allObjects[objData[0]] as GameTexture).clone(objData[1], objData[2]);
							if (newBG is Animation) (newBG as Animation).play();
							addBackground(newBG);
						}
					}
					
					//TODO load tiles if exist
				
					for each (var obj:String in data[3].split("#"))
					{
						objData = obj.split(",");
						if (allObjects[objData[0]] == null)
						{
							trace("Invalid object key: " + objData[0] + ". Skipping entity.");
							continue;
						}
						if (objData.length == 3)
						{
							var newObj:GameObject = (allObjects[objData[0]] as GameObject).clone(objData[1], objData[2]);
							addObject(newObj);
						}
						else if (objData.length == 5)
						{
							var newLine:Line = (allObjects[objData[0]] as Line).clone(objData[1], objData[2], objData[3], objData[4]);
							addLine(newLine);
						}
					}
				
					for each (var infoObj:String in data[4].split("#"))
					{
						objData = infoObj.split("=");
						if (objData.length < 2)
						{
							trace("No value for info object " + objData[0]);
							continue;
						}
						switch (objData[0])
						{
							case "gravity": info["gravity"] = parseFloat(objData[1]); break;
							case "friction": info["friction"] = parseFloat(objData[1]); break;
							case "wind": info["wind"] = parseFloat(objData[1]); break;
							case "name": info["lvlName"] = objData[1]; break;
							case "hasBorders": info["hasBorders"] = objData[1] == 1 ? true : false; break;
							case "drawBorders": info["drawBorders"] = objData[1] == 1 ? true : false; break;
							case "borderColor": info["borderColor"] = objData[1]; break;
							default: trace("Invalid info key: " + objData[0] + ". Skipping."); break;
						}
					}
				}
			}
			if (info["hasBorders"]) createBorders(info["drawBorders"], info["borderColor"]);
			
			game.onLevelLoaded();
		}
		
		private function createBorders(visible:Boolean = true, color:Number = 0x000000):void
		{
			addLine(new Line(visible, .1, .1, grid.gridWidth * grid.cellWidth - .1, .1, color));
			addLine(new Line(visible, grid.gridWidth * grid.cellWidth - .1, .1, grid.gridWidth * grid.cellWidth - .1, grid.gridHeight * grid.cellHeight - .1, color));
			addLine(new Line(visible, grid.gridWidth * grid.cellWidth - .1, grid.gridHeight * grid.cellHeight - .1, .1, grid.gridHeight * grid.cellHeight - .1, color));
			addLine(new Line(visible, .1, grid.gridHeight * grid.cellHeight - .1, .1, .1, color));
		}
		
		public function resetToDefaults():void
		{
			info["gravity"] = defaultInfo["gravity"];
			info["friction"] = defaultInfo["friction"];
			info["wind"] = defaultInfo["wind"];
			info["hasBorders"] = defaultInfo["hasBorders"];
			info["drawBorders"] = defaultInfo["drawBorders"];
			info["borderColor"] = defaultInfo["borderColor"];
		}
		
		public function getObjectByID(id:int):GameObject
		{
			return _objects[id];
		}
		
		public function assignKey(key:String, object:Object):void
		{
			allObjects[key] = object;
		}
		
		public function clear():void
		{
			_objects = new Vector.<GameObject>();
			_lines = new Vector.<Line>();
			_backgrounds = new Vector.<GameTexture>();
			while (numChildren > 0) removeChildAt(0);
			grid = new Grid(this, 0, 0, 0, 0);
			resetToDefaults();
		}
		
		public function handleKeyEvent(keysPressed:Vector.<uint>):void
		{
			for each (var obj:GameObject in _objects) if (obj.controllable) obj.handleKeys(keysPressed);
		}
	}
}