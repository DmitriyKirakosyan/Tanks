package game.tank {

import game.IControllerWithTime;
import game.events.TankShotingEvent;
import game.events.TankEvent;
import game.tank.TankController;
import game.matrix.MapMatrix;
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
		
		
		public function TargetsController(container:Sprite, mapMatrix:MapMatrix) {
			_container = container;
			_mapMatrix = mapMatrix;
			_enemyControllers = new Vector.<TankController>();
			initTimer();
		}
		

		public function addPlayerTank(tank:Tank):void {
			_playerTank = tank;
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
		
		public function get enemyes():Vector.<Tank> { return getEnemyTanks(); }
		public function get enemyesController():Vector.<TankController> { return _enemyControllers; }
		
		public function killEnemyTank(tank:Tank):void {
			for  (var i:int = 0; i < _enemyControllers.length; ++i) {
				if (_enemyControllers[i].tank == tank) {
					_enemyControllers[i].bam();
					removeEnemyTankListeners(_enemyControllers[i]);
					_enemyControllers.splice(i, 1);
					tank.removeChild(tank.liveTab);
					break;
				}
			}
		}

		public function init():void {
			for (var i:int = 0; i < Math.random() * 5; i++) { createTarget(); }
			startTimer();
		}

		public function remove():void {
			_timer.stop();
			for each (var enemy:TankController in _enemyControllers) {
				enemy.remove();
			}
			_enemyControllers = new Vector.<TankController>();
		}
		
		/* Internal functions */
		
		private function createTarget():void {
			var enemyTank:TankController = new TankController(_container, _mapMatrix);
			enemyTank.init(new TankVO());
			var rndX:int = Math.random() * MapMatrix.MATRIX_WIDTH;
			var rndY:int = Math.random() * MapMatrix.MATRIX_HEIGHT;
			enemyTank.tank.x = rndX;
			enemyTank.tank.y = rndY;
			enemyTank.setAutoAttack(_playerTank);
			_enemyControllers.push(enemyTank);
			moveEnemyTank(enemyTank);
			enemyTank.addEventListener(TankEvent.MOVING_COMPLETE, onEnemyMovingComplete);
			enemyTank.addEventListener(TankShotingEvent.WAS_SHOT, onEnemyShotEvent);
			dispatchEvent(new TargetsControllerEvent(TargetsControllerEvent.NEW_TANK, enemyTank.tank));
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
			const toPoint:Point = new Point(int(Math.random()*MapMatrix.MATRIX_WIDTH),
																		int(Math.random()*MapMatrix.MATRIX_HEIGHT));
			const path:Vector.<Point> = 
				Pathfinder.getPath(new Point(enemyTankController.tank.x, enemyTankController.tank.y),
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




