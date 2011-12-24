package game.Debug.DebugObjects {
	import flash.display.Sprite;

	public class Buttons extends Sprite {
		
		private var _stopAddTankButton:StopAddBtn;
		private var _dragTankButton:TankMoveBtn;
		private var _removeMapObjButton:DelObjBtn;
		private var _addBrickBtn:AddBrickBtn;
		private var _addStoneBtn:AddStoneBtn;
		private var _saveMapBtn:SaveMap;
        private var _loadMapBtn:LoadMap;
		private var _trashBtn:TrashBtn;
		
		private var _pauseGameBtn:PauseGame;
		private var _changeGunBtn:ChangeGun;
		private var _newGameBtn:NewGame;
		
		
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
        public function get loadMapBtn():LoadMap { return _loadMapBtn; }
		public function get trashBtn():TrashBtn { return _trashBtn; }
		public function get pauseGameBtn():PauseGame { return _pauseGameBtn; }
		public function get changeGunBtn():ChangeGun { return _changeGunBtn; }
		public function get newGameBtn():NewGame { return _newGameBtn; }
		
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
			_saveMapBtn.scaleX = _saveMapBtn.scaleY = .22;
			_saveMapBtn.x = 345;
			_saveMapBtn.y = 20;
			super.addChild(_saveMapBtn);

            _loadMapBtn = new LoadMap();
			_loadMapBtn.scaleX = _loadMapBtn.scaleY = .22;
			_loadMapBtn.x = 385;
			_loadMapBtn.y = 20;
			super.addChild(_loadMapBtn);

			_trashBtn = new TrashBtn();
			_trashBtn.scaleX = _trashBtn.scaleY = .3;
			_trashBtn.x = 550;
			_trashBtn.y = 20;
			super.addChild(_trashBtn);
			
			_pauseGameBtn = new PauseGame();
			_pauseGameBtn.scaleX = _pauseGameBtn.scaleY = 1;
			_pauseGameBtn.x = 500;
			_pauseGameBtn.y = 20;
			_pauseGameBtn.gotoAndStop(1);
			super.addChild(_pauseGameBtn);
			
			_changeGunBtn = new ChangeGun();
			_changeGunBtn.scaleX = _changeGunBtn.scaleY = 1;
			_changeGunBtn.x = 460;
			_changeGunBtn.y = 20;
			super.addChild(_changeGunBtn);
			
			_newGameBtn = new NewGame();
			_newGameBtn.scaleX = _newGameBtn.scaleY = 1;
			_newGameBtn.x = 420;
			_newGameBtn.y = 20;
			super.addChild(_newGameBtn);
		}
	}
}
