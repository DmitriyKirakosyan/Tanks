package game.Debug {
	import game.matrix.MapMatrix;
	import com.greensock.events.TweenEvent;
	import game.Debug.DebugObjects.Buttons;
import game.tank.TankBotController;
import game.tank.TankController;
	import flash.filters.GlowFilter;
	import game.tank.Tank;
	import flash.events.MouseEvent;
	import game.GameController;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;

	import com.greensock.*;


	public class DebugController extends EventDispatcher {
 		
		private var _gameController:GameController;
		private var _debugContainer:Sprite;
		private var _buttons:Buttons;
		private var _container:Sprite;
		private var _matrix:Sprite;
		
		private var _stopAddTank:Boolean = false;
		private var _tankDrag:Boolean = false;
		private var _tikTak:Boolean = false;
		private var _gunType:uint = 0;
		
		private var _playerTank:Tank;
		private var _enemies:Vector.<Tank>;
		private var _enemyControllers:Vector.<TankBotController>;
		
		private var _tween:Boolean = false;
		
		public function DebugController(container:Sprite, gameController:GameController):void {
			super();
			_debugContainer = container;
			_container = new Sprite();
			_container.graphics.lineStyle(2, 0x999999);
			_container.graphics.beginFill(0xD4D4D4, .5);
			_container.graphics.drawRoundRect(5, -110, 590, 80, 10);
			_container.graphics.endFill();
			_gameController = gameController;
			
			_debugContainer.addEventListener(MouseEvent.CLICK, onKeyDown);
		}
			
		public function open():void {
			drawMatrix();
			createButtons();
			addButtons();
		}
		public function close():void {
			removeButtons();
			removeOtherObjListeners();
			_debugContainer.removeChild(_matrix);
		}
		
		
		//TODO убрать баги с движением врага, доделать столкновение с пулей. после передвижений, 
		//остальные танки стреляют в точку где танк был опущен
		
		/* Internal functions */
		
		private function onKeyDown(event:MouseEvent):void {
			if (event.ctrlKey) {
				if(!_tween) {
					//_container.visible = !_container.visible;
					TweenLite.to(_container, .5, {x: 0, y : 100 });
					_tween = true;
					_matrix.visible = true;
					return;
				}
				if(_tween) {
					TweenLite.to(_container, 1, {x: 0, y : -100 });
					//_container.visible = !_container.visible;
					_tween = false;
					_matrix.visible = false;
					return;
				}
			}
		}
		
		public function drawMatrix():void {
			_matrix = new Sprite();
			_matrix.visible = false;
			_matrix.graphics.lineStyle(1, 0x00FF00, .4);
			for (var i:int = 0; i <= MapMatrix.MATRIX_WIDTH; ++i) {
				_matrix.graphics.moveTo(i * GameController.CELL, 0);
				_matrix.graphics.lineTo(i * GameController.CELL, MapMatrix.MATRIX_HEIGHT * GameController.CELL);
			}
			for (var j:int = 0; j <= MapMatrix.MATRIX_HEIGHT; ++j) {
				_matrix.graphics.moveTo(0, j * GameController.CELL);
				_matrix.graphics.lineTo(MapMatrix.MATRIX_WIDTH * GameController.CELL, j * GameController.CELL);
			}
			_debugContainer.addChild(_matrix);
			_debugContainer.addChild(_container);
		}
		
		private function createButtons():void {
			_buttons = new Buttons();
			_buttons.x = 10;
			_buttons.y = -90;
			_container.addChild(_buttons);
		}
		private function addButtons():void {
			_buttons.stopAddTankButton.addEventListener(MouseEvent.CLICK, tankAddController);
			_buttons.dragTankButton.addEventListener(MouseEvent.CLICK, enemyTankMoveController);
			_buttons.removeMapObjButton.addEventListener(MouseEvent.CLICK, removeMapObjects);
			_buttons.addBrickBtn.addEventListener(MouseEvent.CLICK, addBrick);
			_buttons.addStoneBtm.addEventListener(MouseEvent.CLICK, addStone);
			_buttons.saveMapBtn.addEventListener(MouseEvent.CLICK, saveMap);
            _buttons.loadMapBtn.addEventListener(MouseEvent.CLICK, loadMap);
			_buttons.pauseGameBtn.addEventListener(MouseEvent.CLICK, pauseGame);
			_buttons.changeGunBtn.addEventListener(MouseEvent.CLICK, changeGun);
			_buttons.newGameBtn.addEventListener(MouseEvent.CLICK, newGame);
			_playerTank = _gameController.targetsController.playerTank;
			_enemies = _gameController.targetsController.enemies;
			_enemyControllers = _gameController.targetsController.enemyControllers;
		}
		private function removeButtons():void {
			if (_debugContainer.contains(_container)) {
				_debugContainer.removeChild(_container);
				_buttons.stopAddTankButton.removeEventListener(MouseEvent.CLICK, tankAddController);
				_buttons.dragTankButton.removeEventListener(MouseEvent.CLICK, enemyTankMoveController);
				_buttons.removeMapObjButton.removeEventListener(MouseEvent.CLICK, removeMapObjects);
				_buttons.addBrickBtn.removeEventListener(MouseEvent.CLICK, addBrick);
				_buttons.addStoneBtm.removeEventListener(MouseEvent.CLICK, addStone);
				_buttons.saveMapBtn.removeEventListener(MouseEvent.CLICK, saveMap);
				_buttons.pauseGameBtn.removeEventListener(MouseEvent.CLICK, pauseGame);
				_buttons.changeGunBtn.removeEventListener(MouseEvent.CLICK, changeGun);
				_buttons.newGameBtn.removeEventListener(MouseEvent.CLICK, newGame);
			}
		}
		private function removeOtherObjListeners():void {
			if (_container.contains(_buttons)) { _container.removeChild(_buttons); }
		}
		/*Map Editor*/
		private function removeMapObjects(event:MouseEvent):void {
			_gameController.mapObjectsController.removeMapObjects();
		}
		
		private function addBrick(event:MouseEvent):void {
			event.stopPropagation();
			_gameController.mapEditor.takeBrick();
		}
		private function addStone(event:MouseEvent):void {
			event.stopPropagation();
			_gameController.mapEditor.takeStone();
		}
		private function saveMap(event:MouseEvent):void {
			_gameController.mapEditor.saveMap();
		}
		private function loadMap(event:MouseEvent):void {
            _gameController.mapEditor.loadMap();
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
				if (enemy.hitTestPoint(_debugContainer.mouseX, _debugContainer.mouseY)) {
					
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
			_gameController.container.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove); //TODO
			playTank(_playerTank);
		}
			
		private function onMouseMove(event:MouseEvent):void {
			_playerTank.originX = _debugContainer.mouseX;
			_playerTank.originY = _debugContainer.mouseY;
		}
		
		private function stopTank(tank:Tank):void {
			for each (var tankController:TankController in _enemyControllers) {
				if (tank == tankController.tank) {
					/*tankController.movingTimeline.vars["onComplete"] = null;
					tankController.movingTimeline.killTweensOf(tank);*/
					tankController.pause();
					break;
				}
			}
		}
		private function playTank(tank:Tank):void {
			for each (var tankController:TankController in _enemyControllers) {
				if (tank == tankController.tank) {
					_gameController.targetsController.moveEnemy = tankController;
					_gameController.container.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
					break;
				}
			}
		}
		
		//Pause & Resume Game
		private function pauseGame(event:MouseEvent):void {
			if (!_tikTak) { _gameController.timeController.pauseWorld(); _buttons.pauseGameBtn.gotoAndStop(2); _tikTak = true; return; }
			if (_tikTak) { _gameController.timeController.resumeWorld(); _buttons.pauseGameBtn.gotoAndStop(1); _tikTak = false; return; }
		}
		//Change Gun
		private function changeGun(event:MouseEvent):void {
			switch (_gunType) {
				case 0 :
					_gameController.playerTankController.tank.updateGun(0);
					_gunType = 1;
					break;
				case 1 :
					_gameController.playerTankController.tank.updateGun(1);
					_gunType = 2;
					break;
				case 2 :
					_gameController.playerTankController.tank.updateGun(2);
					_gunType = 0;
					break;
				default : return;
			}
		}
		//Restart Game
		private function newGame(event:MouseEvent):void {
			_gameController.startNewGame();
		}
	}
}
