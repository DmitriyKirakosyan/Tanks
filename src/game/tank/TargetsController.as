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
		private var _enemyControllers:Vector.<TankBotController>;
		private var _container:Sprite;
		private var _mapMatrix:MapMatrix;
		private var _playerTank:Tank;
		private var _levelStrength:Number;
		
		public function TargetsController(container:Sprite, mapMatrix:MapMatrix) {
			_container = container;
			_mapMatrix = mapMatrix;
			_enemyControllers = new Vector.<TankBotController>();
			initTimer();
		}

		public function addPlayerTank(tank:Tank):void {
			_playerTank = tank;
			for each (var tankController:TankBotController in _enemyControllers) {
				if (!tankController.hasTargetTank()) { tankController.setTargetTank(tank); }
			}
		}

		/* time functions */

		public function scaleTime(value:Number):void {
			for each (var tankController:TankController in _enemyControllers) {
				tankController.scaleTime(value);
			}
		}

		public function pause():void {
			for each (var tankController:TankController in _enemyControllers) {
				tankController.pause();
			}
		}
		public function resume():void {
			for each (var tankController:TankController in _enemyControllers) {
				tankController.resume();
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
					_levelStrength += .3;
					break;
				}
			}
		}

		public function cleanTargetTank():void {
			for each (var tankController:TankBotController in _enemyControllers) {
				tankController.removeTargetTank();
				_playerTank = null;
			}
		}

		public function init():void {
			_levelStrength = .01;
			for (var i:int = 0; i < Math.random() * 7; i++) { createTarget(); }
			startTimer();
		}

		public function remove():void {
			_timer.stop();
			for each (var enemy:TankController in _enemyControllers) {
				removeEnemyTankListeners(enemy);
				enemy.remove();
			}
			_enemyControllers = new Vector.<TankBotController>();
		}

		public function strengthOf(tank:Tank):uint {
			var result = TankBotController.BASE_BOT;
			for each (var tankController in _enemyControllers) {
				if (tankController.tank == tank) {
					result = tankController.strength;
					break;
				}
			}
			return result;
		}
		
		/* For Debug */
		
		public function get enemies():Vector.<Tank> { return getEnemyTanks(); }
		public function get enemyControllers():Vector.<TankBotController> { return _enemyControllers; }
		public function get timerAddTank():Timer { return _timer; }
		public function get playerTank():Tank { return _playerTank; }
		public function set moveEnemy(value:TankController):void { moveEnemyTank(value); }
		
		/* Internal functions */
		
		private function createTarget():void {
			// 0 - BaseBot, 1 - AdvanceBot, 2 - HardBot
			var strength:int = Math.random() < 1/_levelStrength ? 0 : Math.random()< 1/_levelStrength*5 ? 1 : 2;
			var enemyTank:TankBotController = new TankBotController(_container, _mapMatrix, strength);
			enemyTank.addEventListener(TankEvent.MOVING_COMPLETE, onEnemyMovingComplete);
			enemyTank.addEventListener(TankShotingEvent.WAS_SHOT, onEnemyShotEvent);

			var tankVO:TankVO = new TankVO();
			tankVO.weaponType = int(Math.random() * 3);
			enemyTank.init(tankVO);
			moveEnemyFromBackstage(enemyTank);
			if (_playerTank && !enemyTank.hasTargetTank()) { enemyTank.setTargetTank(_playerTank); }
			_enemyControllers.push(enemyTank);
		}

		private function moveEnemyFromBackstage(enemy:TankController):void {
			var rnd:Number = Math.random();
			trace("rnd "  + rnd);
			var x:Number = rnd < .5 ? (1 + int(rnd*2 * (MapMatrix.MATRIX_WIDTH-1))) : rnd < 7.5 ? -1 : MapMatrix.MATRIX_WIDTH;
			var y:Number = rnd > .5 ? (1 + int((rnd-.5)*2 * (MapMatrix.MATRIX_HEIGHT-1))) : rnd < 2.5 ? -1 : MapMatrix.MATRIX_HEIGHT;
			trace("x : " + x + ", y : " + y);
			enemy.tank.x = x;
			enemy.tank.y = y;
			moveEnemyTank(enemy);
			var toPoint:Point;
			if (x < 0) { toPoint = new Point(x + 1, y);
			} else if (x == MapMatrix.MATRIX_WIDTH) { toPoint = new Point(x-1, y);
			} else if (y < 0) { toPoint = new Point(x,  y + 1);
			} else { toPoint = new Point(x, y-1); }

			const path:Vector.<Point> = new Vector.<Point>();
			path.push(toPoint);
			addPathToEnemyTankController(path, enemy);
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
				var numAttempts:int = 30;
				var attemptsCounter:int = 0;
				do {
					toPoint = new Point(int(Math.random()*MapMatrix.MATRIX_WIDTH),
															int(Math.random()*MapMatrix.MATRIX_HEIGHT));
					attemptsCounter++;
				} while (!_mapMatrix.isFreeCell(toPoint.x, toPoint.y) && attemptsCounter < numAttempts);
				if (!_mapMatrix.isFreeCell(toPoint.x, toPoint.y)) {
					trace("ops");
					toPoint = new Point(enemyTankController.tank.x == 0 ? enemyTankController.tank.x + 1 :
															enemyTankController.tank.x - 1, enemyTankController.tank.y);
				}
			} else {
				toPoint.x = int(toPoint.x);
				toPoint.y = int(toPoint.y);
			}
			const path:Vector.<Point> = Pathfinder.getPath(new Point(enemyTankController.tank.x, enemyTankController.tank.y),
																										toPoint);
			addPathToEnemyTankController(path, enemyTankController);
		}	
	
		private function addPathToEnemyTankController(path:Vector.<Point>, enemyTankController:TankController):void {
			enemyTankController.setMovingPath(path);
		}
		
		private function createTargetForTimer (event:TimerEvent):void {
			if (_enemyControllers.length < 5 && Math.random() < .5) {
				createTarget();
			}
		}
		
		private function initTimer():void {
			_timer = new Timer(5000);
			_timer.addEventListener(TimerEvent.TIMER, createTargetForTimer);
		}
		
		private function startTimer():void {
			_timer.start();
		}
	}
}




