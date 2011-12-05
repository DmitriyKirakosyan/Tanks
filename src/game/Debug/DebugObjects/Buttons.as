package game.Debug.DebugObjects {
	import flash.display.Sprite;

	public class Buttons extends Sprite {
		
		private var _stopAddTankButton:StopAddBtn;
		private var _dragTankButton:TankMoveBtn;
		private var _removeMapObjButton:DelObjBtn;
		private var _addBrickBtn:AddBrickBtn;
		private var _addStoneBtn:AddStoneBtn;
		private var _saveMapBtn:SaveMap;
		private var _trashBtn:TrashBtn;
		
		
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
		public function get saveMapBtn():SaveMap { return _saveMapBtn; }
		public function get trashBtn():TrashBtn { return _trashBtn; }
		
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
			
			_saveMapBtn = new SaveMap();
			_saveMapBtn.scaleX = _saveMapBtn.scaleY = .3;
			_saveMapBtn.x = 370;
			_saveMapBtn.y = 20;
			super.addChild(_saveMapBtn);
			
			_trashBtn = new TrashBtn();
			_trashBtn.scaleX = _trashBtn.scaleY = .3;
			_trashBtn.x = 500;
			_trashBtn.y = 20;
			super.addChild(_trashBtn);
		}
	}
}
