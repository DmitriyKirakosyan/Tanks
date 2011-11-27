package game.Debug.DebugObjects {
	import flash.display.Sprite;

	public class Buttons extends Sprite {
		
		private var _stopAddTankButton:StopAddBtn;
		private var _dragTankButton:TankMoveBtn;
		private var _removeMapObjButton:DelObjBtn;
		private var _addBrickBtn:AddBrickBtn;
		private var _addStoneBtn:AddStoneBtn;
		
		
		public function Buttons():void {
			super();
			createDebugButtons();
			this.buttonMode = true;
		}
		
		public function get stopAddTankButton():StopAddBtn { return _stopAddTankButton; }
		public function get dragTankButton():TankMoveBtn { return _dragTankButton; }
		public function get removeMapObjButton():DelObjBtn { return _removeMapObjButton; }
		public function get addBrickBtn():AddBrickBtn { return _addBrickBtn; }
		public function get addStoneBtm():AddStoneBtn { return _addStoneBtn; }
		
		/* Internal functions */
		
		private function createDebugButtons():void {
			_stopAddTankButton = new StopAddBtn();
			_stopAddTankButton.scaleX = _stopAddTankButton.scaleY = .3;
			_stopAddTankButton.x = 20;
			_stopAddTankButton.y = 20;
			super.addChild(_stopAddTankButton);
			
			_dragTankButton = new TankMoveBtn();
			_dragTankButton.scaleX = _dragTankButton.scaleY = .3;
			_dragTankButton.x = 90;
			_dragTankButton.y = 20;
			super.addChild(_dragTankButton);
			
			_removeMapObjButton = new DelObjBtn();
			_removeMapObjButton.scaleX = _removeMapObjButton.scaleY = .3;
			_removeMapObjButton.x = 160;
			_removeMapObjButton.y = 20;
			super.addChild(_removeMapObjButton);
			
			_addBrickBtn = new AddBrickBtn();
			_addBrickBtn.scaleX = _addBrickBtn.scaleY = .3;
			_addBrickBtn.x = 230;
			_addBrickBtn.y = 20;
			super.addChild(_addBrickBtn);
			
			_addStoneBtn = new AddStoneBtn();
			_addStoneBtn.scaleX = _addStoneBtn.scaleY = .3;
			_addStoneBtn.x = 300;
			_addStoneBtn.y = 20;
			super.addChild(_addStoneBtn);
		}
	}
}
