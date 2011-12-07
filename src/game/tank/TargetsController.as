package game.tank {
import game.IControllerWithTime;
import game.events.TankShotingEvent;
import game.events.TankEvent;
import game.matrix.MapMatrix;
import game.tank.TankBotController;

import pathfinder.Pathfinder;
import game.events.TargetsControllerEvent;

import flash.geom.Point;
import flash.events.EventDispatcher;
import flash.display.Sprite;
import flash.events.TimerEvent;
import flash.utils.Timer;
	
	public class TargetsController extends EventDispatcher implements IControllerWithTime{
		private var _timer:Timer;
		private var _enemyControllers:Vector.<TankController>;
		private var _container:Sprite;
		private var _mapMatrix:MapMatrix;
		
		
		private var _playerTank:Tank;
		
		private var _random:Number;
		private var _firstMove:Boolean = true;
		
		
		public function TargetsController(container:Sprite, mapMatrix:MapMatrix) {
			_container = container;
			_mapMatrix = mapMatrix;
			_enemyControllers = new Vector.<TankController>();
			initTimer();
		}
		

		public function addPlayerTank(tank:Tank):void {
			_playerTank = tank;
			for each (var tankController:TankController in _enemyControllers) {
				if (!tankController.hasTargetTank()) { tankController.setTargetTank(tank); }
			}
		}
		
		public function scaleTime(value:Number):void {
			for each (var tankController:TankController in _enemyControllers) {
				tankController.scaleTime(value);
			}
		}
		
		public function getEnemyTanks():Vector.<Tank> {
			const tanks:Vector.<Tank> = new Vector.<Tank>();
			for each (var tankController:TankController in _enemyControllers) {
				tanks.push(tankController.tank);
			}
			return tanks;
		}
		
		public function killEnemyTank(tank:Tank):void {
			for  (var i:int = 0; i < _enemyControllers.length; ++i) {
				if (_enemyControllers[i].tank == tank) {
					_enemyControllers[i].bam();
					removeEnemyTankListeners(_enemyControllers[i]);
					_enemyControllers.splice(i, 1);
					break;
				}
			}
		}

		public function cleanTargetTank():void {
			for each (var tankController:TankController in _enemyControllers) {
				tankController.removeTargetTank();
				_playerTank = null;
			}
		}

		public function init():void {
			for (var i:int = 0; i < Math.random() * 3; i++) { createTarget(); }
			startTimer();
		}

		public function remove():void {
			_timer.stop();
			for each (var enemy:TankController in _enemyControllers) {
				removeEnemyTankListeners(enemy);
				enemy.remove();
			}
			_enemyControllers = new Vector.<TankController>();
		}
		
		/* For Debug */
		
		public function get enemies():Vector.<Tank> { return getEnemyTanks(); }
		public function get enemyControllers():Vector.<TankController> { return _enemyControllers; }
		public function get timerAddTank():Timer { return _timer; }
		public function get playerTank():Tank { return _playerTank; }
		public function set moveEnemy(value:TankController):void { moveEnemyTank(value); }
		
		/* Internal functions */
		
		private function createTarget():void {
			var strength:int = int(Math.random() * 3);
			var enemyTank:TankController = new TankBotController(_container, _mapMatrix, strength);
			var tankVO:TankVO = new TankVO();
			tankVO.weaponType = 1;
			enemyTank.init(new TankVO());
			var rndX:int = Math.random() * MapMatrix.MATRIX_WIDTH;
			var rndY:int = Math.random() * MapMatrix.MATRIX_HEIGHT;
			enemyTank.tank.x = rndX;
			enemyTank.tank.y = rndY;
			if (_playerTank && !enemyTank.hasTargetTank()) { enemyTank.setTargetTank(_playerTank); }
			_enemyControllers.push(enemyTank);
			moveEnemyTank(enemyTank);
			enemyTank.addEventListener(TankEvent.MOVING_COMPLETE, onEnemyMovingComplete);
			enemyTank.addEventListener(TankShotingEvent.WAS_SHOT, onEnemyShotEvent);
		}
		private function removeEnemyTankListeners(enemyTankController:TankController):void {
			enemyTankController.removeEventListener(TankShotingEvent.WAS_SHOT, onEnemyShotEvent);
			enemyTankController.removeEventListener(TankEvent.MOVING_COMPLETE, onEnemyMovingComplete);
		}
		
		private function onEnemyMovingComplete(event:TankEvent):void {
				moveEnemyTank(event.tankController);
		}
		
		private function onEnemyShotEvent(event:TankShotingEvent):void {
			dispatchEvent(new TankShotingEvent(TankShotingEvent.WAS_SHOT, event.bullet));
		}
		
		
		private function moveEnemyTank(enemyTankController:TankController):void {

			var toPoint:Point = (TankBotController(enemyTankController)).getTargetMovePoint();
			if (!toPoint) {
				toPoint = new Point(int(Math.random()*MapMatrix.MATRIX_WIDTH),
														int(Math.random()*MapMatrix.MATRIX_HEIGHT));
			} else {
				toPoint.x = int(toPoint.x);
				toPoint.y = int(toPoint.y);
			}
			const path:Vector.<Point> = Pathfinder.getPath(new Point(enemyTankController.tank.x, enemyTankController.tank.y),
																										toPoint);
			addPathToEnemyTankController(path, enemyTankController);
		}	
	
		private function addPathToEnemyTankController(path:Vector.<Point>, enemyTankController:TankController):void {
			enemyTankController.readyForMoving();
			for each (var point:Point in path) {
				enemyTankController.addPointToMovePath(point);
			}
		}
		
		private function createTargetforTimer (event:TimerEvent):void {
			if (_enemyControllers.length < 5 && Math.random() < .5) {
				createTarget();
			}
		}
		
		private function initTimer():void {
			_timer = new Timer(5000);
			_timer.addEventListener(TimerEvent.TIMER, createTargetforTimer);
		}
		
		private function startTimer():void {
			_timer.start();
		}
	}
}




