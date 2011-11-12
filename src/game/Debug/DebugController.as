package game.Debug {
	import game.tank.TankController;
	import flash.filters.GlowFilter;
	import game.tank.Tank;
	import flash.events.MouseEvent;
	import game.GameController;
	import game.mapObjects.Buttons;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;



	public class DebugController extends EventDispatcher {
		
		private var _gameController:GameController;
		private var _debugContainer:Sprite;
		private var _buttons:Buttons;
		private var _container:Sprite;
		
		private var _stopAddTank:Boolean = false;
		private var _tankDrag:Boolean = false;
		
		private var _playerTank:Tank;
		private var _enemies:Vector.<Tank>;
		private var _enemiesController:Vector.<TankController>;
		
		public function DebugController(container:Sprite, gameController:GameController):void {
			super();
			_debugContainer = container;
			_container = new Sprite();
			_container.visible = false;
			_gameController = gameController;
			createButtons();
			
			_debugContainer.addEventListener(MouseEvent.CLICK, onKeyDown);
		}
			
		public function open():void {
			addButtons();
		}
		public function close():void {
			removeButtons();	
		}
		
		//TODO убрать баги с движением врага, доделать столкновение с пулей. после передвижений, 
		//остальные танки стреляют в точку где танк был опущен
		
		/* Internal functions */
		
		private function onKeyDown(event:MouseEvent):void {
			if (event.ctrlKey) {
				_container.visible = !_container.visible;
			}
		}
		private function createButtons():void {
			_buttons = new Buttons();
			_buttons.x = 10;
			_buttons.y = 10;
			_container.addChild(_buttons);
		}
		private function addButtons():void {
			_debugContainer.addChild(_container);
			_buttons.stopAddTankButton.addEventListener(MouseEvent.CLICK, tankAddController);
			_buttons.dragTankButton.addEventListener(MouseEvent.CLICK, enemyTankMoveController);
			_playerTank = _gameController.targetsController.playerTank;
			_enemies = _gameController.targetsController.enemies;
			_enemiesController = _gameController.targetsController.enemyControllers;
		}
		private function removeButtons():void {
			if (_debugContainer.contains(_container)) {
				_debugContainer.removeChild(_container);
				_buttons.stopAddTankButton.removeEventListener(MouseEvent.CLICK, tankAddController);
				_buttons.dragTankButton.removeEventListener(MouseEvent.CLICK, enemyTankMoveController);
			}
		}
		
		/* Add Enemy or Not */
		private function tankAddController(event:MouseEvent):void {
			if (!_stopAddTank) {
				_stopAddTank = true;
				_gameController.targetsController.timerAddTank.stop();
				_buttons.stopAddTankButton.alpha = .5;
				trace("[DebugController] StopTankAdd"); }
			else if (_stopAddTank) {
				_stopAddTank = false;
				_gameController.targetsController.timerAddTank.start();
				_buttons.stopAddTankButton.alpha = 1;
				trace("[DebugController] StartTankAdd"); }
		}
		
		/* Move Enemy */
		private function enemyTankMoveController(event:MouseEvent):void {
			if (!_tankDrag) {
				_tankDrag = true;
				_gameController.container.addEventListener(MouseEvent.MOUSE_DOWN, tankMoveON);
				_gameController.container.addEventListener(MouseEvent.MOUSE_UP, tankMoveOFF);
				_buttons.dragTankButton.alpha = .5;
				trace("[DebugController] YES drag");
			}
			else if (_tankDrag) {
				_tankDrag = false;
				_gameController.container.removeEventListener(MouseEvent.MOUSE_DOWN, tankMoveON);
				_gameController.container.removeEventListener(MouseEvent.MOUSE_UP, tankMoveOFF);
				_buttons.dragTankButton.alpha = 1;
				trace("[DebugController] NOT drag");
			}
		}
		private function tankMoveON(event:MouseEvent):void {
			for each (var enemy:Tank in _enemies) {
				if (enemy.hitTestPoint(_container.mouseX, _container.mouseY)) {
					enemy.tankUseMouse = true;
					_playerTank = enemy;
					stopTank(enemy);
					_gameController.container.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
					enemy.filters = [new GlowFilter(0x00FF00, .9)];
					break;
				}		
			}
		}
		private function tankMoveOFF(event:MouseEvent):void {
			_playerTank.filters = null;
			_playerTank.tankUseMouse = false;
			_gameController.container.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove); //TODO
			playTank(_playerTank);
		}
			
		private function onMouseMove(event:MouseEvent):void {
			_playerTank.originX = _gameController.container.mouseX;
			_playerTank.originY = _gameController.container.mouseY;
		}
		
		private function stopTank(tank:Tank):void {
			for each (var tankController:TankController in _gameController.targetsController.enemyControllers) {
				if (tank == tankController.tank) {
					tankController.movingTimeline.vars["onComplete"] = null;
					tankController.movingTimeline.killTweensOf(tank);
					tankController.autoAttackTimer.stop();
					break;
				}
			}
		}
		private function playTank(tank:Tank):void{
			for each (var tankController:TankController in _enemiesController) {
				if (tank == tankController.tank) {
						_gameController.targetsController.moveEnemy = tankController;
						_gameController.container.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
						tankController.autoAttackTimer.start();
					break;
				}
			}
		}
	}
}
