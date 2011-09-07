package game {
import flash.events.EventDispatcher;

import game.events.DamageObjectEvent;
import game.events.SceneEvent;

import pathfinder.Pathfinder;
	import game.tank.Tank;
	import game.events.TargetsControllerEvent;
	import game.events.TankShotingEvent;
	import flash.geom.Point;
	import flash.events.MouseEvent;
	import game.events.MineBamEvent;
	import game.mapObjects.MapObjectsController;
	import game.events.DrawingControllerEvent;
	import game.drawing.MouseDrawController;
	import game.matrix.MapMatrix;
	import flash.display.Sprite;
	import game.tank.BulletsController;
	import game.tank.TankController;
	import game.tank.TargetsController;

	public class GameController extends EventDispatcher implements IScene{
		private var _container:Sprite;
		private var _bulletsController:BulletsController;
		private var _tankController:TankController;
		private var _tankMovementListener:TankMovementListener;
		private var _targetsController:TargetsController;
		private var _mapMatrix:MapMatrix;
		private var _mapObjectsController:MapObjectsController;
		private var _mouseDrawController:MouseDrawController;
		private var _timeController:TimeController;
		
		public static const CELL:int = 40;
		
		public function GameController(c:Sprite):void {
			_container = c;
			initControllers();
		}

		public function open():void {
		 	_tankController.init();
			_targetsController.init();
			_mapObjectsController.init();
			initMapObjectsController();
			addListeners();
		}

		public function remove():void {
			removeListeners();
		 	_mapMatrix.remove();
			_mouseDrawController.remove();
			_bulletsController.remove();
			_tankController.remove();
			_targetsController.remove();
			_mapObjectsController.remove();
		}
		
		private function initControllers():void {
			_mapMatrix = new MapMatrix(_container);
			_mapMatrix.drawMatrix();
			Pathfinder.matrix = _mapMatrix.matrix;
			_mouseDrawController = new MouseDrawController(_container, _mapMatrix);
			_bulletsController = new BulletsController(_container);
			_tankController = new TankController(_container, _mapMatrix, true);
			_targetsController = new TargetsController(_container, _mapMatrix, _tankController.tank);
			_mapObjectsController = new MapObjectsController(_mapMatrix, _container);
			_mapObjectsController.addPlayerTank(_tankController.tank);
			_tankMovementListener = new TankMovementListener(_tankController, _mapObjectsController,
																												_mouseDrawController);
			_timeController = new TimeController(_container);
			initTimeController();
		}
		
		private function initTimeController():void {
			_timeController.add_controller(_tankController);
			_timeController.add_controller(_mapObjectsController);
			_timeController.add_controller(_targetsController);
		}
		private function initMapObjectsController():void {
			_mapObjectsController.drawObjects();
			if (_targetsController) {
				const enemyTanks:Vector.<Tank> = _targetsController.getEnemyTanks();
				for each (var tank:Tank in enemyTanks) {
					_mapObjectsController.addEnemyTank(tank);
				}
			}
		}
		
		private function addListeners():void {
			_mouseDrawController.addEventListener(DrawingControllerEvent.WANT_START_DRAW, onWantStartDraw);
			_mouseDrawController.addEventListener(DrawingControllerEvent.NEW_MOVE_POINT, onNewMovePoint);
			_mouseDrawController.addEventListener(DrawingControllerEvent.DRAWING_COMPLETE, onDrawingComplete);
			_mapObjectsController.addEventListener(MineBamEvent.BAM, onMineBam);
			_mapObjectsController.addEventListener(DamageObjectEvent.DAMANGE_ENEMY_TANK, onEnemyDamage);
			_mapObjectsController.addEventListener(DamageObjectEvent.DAMANGE_PLAYER_TANK, onPlayerDamage);
			_tankController.addEventListener(TankShotingEvent.WAS_SHOT, onTankShot);
			_targetsController.addEventListener(TankShotingEvent.WAS_SHOT, onTankShot);
			_targetsController.addEventListener(TargetsControllerEvent.NEW_TANK, onNewEnemyTank);
			listenStageEvents();
		}
		
		private function listenStageEvents():void {
			_container.addEventListener(MouseEvent.CLICK, onStageClick);
		}
		
		private function removeListeners():void {
			_mouseDrawController.removeEventListener(DrawingControllerEvent.WANT_START_DRAW, onWantStartDraw);
			_mouseDrawController.removeEventListener(DrawingControllerEvent.NEW_MOVE_POINT, onNewMovePoint);
			_mouseDrawController.removeEventListener(DrawingControllerEvent.DRAWING_COMPLETE, onDrawingComplete);
			_mapObjectsController.removeEventListener(MineBamEvent.BAM, onMineBam);
			_mapObjectsController.removeEventListener(DamageObjectEvent.DAMANGE_PLAYER_TANK, onPlayerDamage);
			_mapObjectsController.removeEventListener(DamageObjectEvent.DAMANGE_ENEMY_TANK, onEnemyDamage);
			_tankController.removeEventListener(TankShotingEvent.WAS_SHOT, onTankShot);
			_targetsController.removeEventListener(TankShotingEvent.WAS_SHOT, onTankShot);
			_targetsController.removeEventListener(TargetsControllerEvent.NEW_TANK, onNewEnemyTank);
			_container.removeEventListener(MouseEvent.CLICK, onStageClick);
			
		}
		
		/* event handlers */
		
		private function onEnemyDamage(event:DamageObjectEvent):void {
			_targetsController.killEnemyTank(event.object as Tank);
		}
		private function onPlayerDamage(event:DamageObjectEvent):void {
			_tankController.bam();
			_container.addEventListener(MouseEvent.CLICK, onClick);
		}
		private function onClick(event:MouseEvent):void {
			_container.removeEventListener(MouseEvent.CLICK, onClick);
			dispatchEvent(new SceneEvent(SceneEvent.WANT_REMOVE));
		}
		
		private function onStageClick(event:MouseEvent):void {
			const point:Point = new Point(event.stageX, event.stageY);
			if (!_tankController.isPointOnTank(point)) {
				_tankController.shot(point);
			}
		}
		
		private function onMineBam(event:MineBamEvent):void {
			if (Math.abs(_tankController.tank.x - event.minePoint.x) < event.distantion &&
					Math.abs(_tankController.tank.y - event.minePoint.y) < event.distantion) {
				_tankController.bam();
				_container.addEventListener(MouseEvent.CLICK, onClick);
			}
		}
		
		private function onTankShot(event:TankShotingEvent):void {
			_mapObjectsController.addBullet(event.bullet);
		}
		
		private function onNewMovePoint(event:DrawingControllerEvent):void {
			_tankController.addPointToMovePath(_mouseDrawController.getLastMovePoint());
		}
		
		private function onDrawingComplete(event:DrawingControllerEvent):void {
			_timeController.normalize();
		}
		
		private function onWantStartDraw(event:DrawingControllerEvent):void {
			if (_tankController.isPointOnTank(_mouseDrawController.currentMousePoint)) {
				_tankController.readyForMoving();
				_mouseDrawController.startDrawTankPath();
				_timeController.slowDown();
			}
		}
		
		private function onNewEnemyTank(event:TargetsControllerEvent):void {
			_mapObjectsController.addEnemyTank(event.tank);
		}
	}
}