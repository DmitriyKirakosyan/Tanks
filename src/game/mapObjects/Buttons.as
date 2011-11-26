package game.mapObjects {
	import flash.display.SpreadMethod;
	import flash.display.Sprite;

	public class Buttons extends Sprite {
		
		private var _stopAddTankButton:Sprite;
		private var _dragTankButton:Sprite;
		private var _removeMapObjButton:Sprite;
		private var _addBrickBtn:Sprite;
		private var _addStoneBtn:Sprite;
		
		public function Buttons():void {
			super();
			createDebugButtons();
			this.buttonMode = true;
		}
		
		public function get stopAddTankButton():Sprite { return _stopAddTankButton; }
		public function get dragTankButton():Sprite { return _dragTankButton; }
		public function get removeMapObjButton():Sprite { return _removeMapObjButton; }
		public function get addBrickBtn():Sprite { return _addBrickBtn; }
		public function get addStoneBtm():Sprite { return _addStoneBtn; }
		
		/* Internal functions */
		
		private function createDebugButtons():void {
			_stopAddTankButton = addBtn(_stopAddTankButton, 0, 0xFFF000);
			super.addChild(_stopAddTankButton);
			_dragTankButton = addBtn(_dragTankButton, 30, 0x00FF00);
			super.addChild(_dragTankButton);
			_removeMapObjButton = addBtn(_removeMapObjButton, 60, 0x0ffFf0);
			super.addChild(_removeMapObjButton);
			_addBrickBtn = addBtn(_addBrickBtn, 120, 0x654321);
			super.addChild(_addBrickBtn);
			_addStoneBtn = addBtn(_addStoneBtn, 150, 0xFF11FF);
			super.addChild(_addStoneBtn);
		}
		
		private function addBtn(name:Sprite, x:int, color:int):Sprite {
			name = new Sprite();
			name.graphics.lineStyle(1, 0x00000F);
			name.graphics.beginFill(color);
			name.graphics.drawRect(x, 0, 20, 20);
			name.graphics.endFill();
			return name;
		}
	}
}
