package net.mole.base 
{
	import flash.display.Sprite;
	
	/**
	 * A menu to hold multiple Buttons.
	 * @author Mikael Myyrä
	 */
	public class Menu extends Sprite 
	{
		protected var background:GameTexture;
		
		private var buttons:Vector.<Button> = new Vector.<Button>();
		private var _style:MenuStyle;
		public function set style(style:MenuStyle):void { _style = style; /*reset();*/ }
		public function get style():MenuStyle { return _style; }
		
		public static const LAYOUT_COLUMN:MenuStyle = new MenuStyle(false, true, 5);
		public static const LAYOUT_ROW:MenuStyle = new MenuStyle(true, false, 5);
		public static const LAYOUT_CUSTOM:MenuStyle = new MenuStyle(false, false, 0);
		
		/**
		 * Create a new menu instance.
		 * @param	style	The MenuStyle object defining the positioning of buttons.
		 * @param	buttons	A Vector of Buttons to add to this Menu. Can also leave it empty and use AddButton instead.
		 */
		public function Menu(background:GameTexture = null, buttons:Vector.<Button> = null, style:MenuStyle = null)
		{
			if (background != null)
			{
				this.background = background;
				addChild(this.background);
			}
			this._style = style;
			if (_style == null) _style = LAYOUT_CUSTOM;
			if (buttons != null)
				for (var i:int = 0; i < buttons.length; i++)
					addButton(buttons[i], buttons[i].x, buttons[i].y);
		}
		
		/**
		 * Add a button to the menu and automatically position it according to the menu's style.
		 * @param	btn	The button to add.
		 * @param	xOffset	Offset from the default position on the x-axis.
		 * @param	yOffset	Offset from the default position on the y-axis.
		 */
		public function addButton(btn:Button, xOffset:Number = 0, yOffset:Number = 0):void
		{
			var i:uint = buttons.push(btn) - 1;
			if (i > 0)
			{
				if (_style.incrementX) buttons[i].x = buttons[i - 1].x + buttons[i - 1].width + _style.gap;
				else buttons[i].x = 0;
				if (_style.incrementY) buttons[i].y = buttons[i - 1].y + buttons[i - 1].height + _style.gap;
				else buttons[i].y = 0;
				buttons[i].x += xOffset;
				buttons[i].y += yOffset;
				addChild(buttons[i]);
			}
			else addChild(buttons[i]);
		}
		
		/**
		 * Reposition all buttons. Only needed when changing style while running. Not sure is necessary, commented out for now.
		 */
		/*private function reset():void
		{
			for each (var btn:Button in buttons) removeChild(btn);
			var buttonsTemp:Vector.<Button> = buttons;
			buttons = new Vector.<Button>();
			for each (var btn:Button in buttonsTemp) addButton(btn);
		}*/
	}
}