package game {
import flash.events.Event;

import game.Debug.DebugController;
import game.events.DamageObjectEvent;
import game.events.GameBonusEvent;
import game.events.SceneEvent;
import game.mapObjects.MapEditor;
import game.mapObjects.bonus.GameBonus;
import game.tank.TankMovementListener;
import pathfinder.Pathfinder;
import game.tank.Tank;
import game.events.TargetsControllerEvent;
import game.events.TankShotingEvent;
import game.events.MineBamEvent;
import game.mapObjects.MapObjectsController;
import game.events.DrawingControllerEvent;
import game.drawing.MouseDrawController;
import game.matrix.MapMatrix;
import game.tank.TankController;
import game.tank.TargetsController;
import state.UserState;

import flash.events.EventDispatcher;
import flash.geom.Point;
import flash.events.MouseEvent;
import flash.display.Sprite;

public class GameController extends EventDispatcher implements IScene{
		private var _container:Sprite;
		private var _mapEditor:MapEditor;
		private var _tankController:TankController;
		private var _tankMovementListener:TankMovementListener;
		private var _mapMatrix:MapMatrix;
		private var _mapObjectsController:MapObjectsController;
		private var _mouseDrawController:MouseDrawController;
		private var _timeController:TimeController;
		private var _debugController:DebugController;
		private var _mouseDown:Boolean;

		private var _pointUnderMouse:Point;

		public static const CELL:int = 40;
		
		public function GameController(container:Sprite):void {
			_mouseDown = false;
			_container = container;
			_pointUnderMouse = new Point();
			initControllers();
		}

		public function open():void {
			_mapObjectsController.init(); // first of all we need to create map and map objects
		 	_tankController.init(UserState.instance.tankVO, true);
			initMapObjectsController();
			addListeners();
			_debugController.open();
		}

		public function remove():void {
			removeListeners();
		 	_mapMatrix.remove();
			_mouseDrawController.remove();
			_tankController.remove();
			_mapObjectsController.remove();
			_debugController.close();
			_mouseDown = false;
		}
		
		/* For debug */
		
		public function get mapObjectsController():MapObjectsController { return _mapObjectsController; }
		public function get mapEditor():MapEditor { return _mapEditor; }
		public function get targetsController():TargetsController { return _mapObjectsController.targetsController; }
		public function get container():Sprite { return _container; }
		
		/* Inits */
		
		private function initControllers():void {
			_mapMatrix = new MapMatrix(_container);
			_mapMatrix.drawMatrix();
			Pathfinder.setMatrix(_mapMatrix.matrix);
			_mouseDrawController = new MouseDrawController(_container, _mapMatrix);
			trace("[GameController.initControllers] tank base : ", UserState.instance.tankVO.tankBase);
			_tankController = new TankController(_container, _mapMatrix);
			_mapObjectsController = new MapObjectsController(_mapMatrix, _container);
			_tankMovementListener = new TankMovementListener(_tankController, _mapObjectsController, _mouseDrawController);
			_timeController = new TimeController(_container);
			_debugController = new DebugController(_container, this);
			_mapEditor = new MapEditor(_container, _mapObjectsController, _mapMatrix);
			initTimeController();
		}
		
		private function initTimeController():void {
			_timeController.add_controller(_tankController);
			_timeController.add_controller(_mapObjectsController);
		}
		private function initMapObjectsController():void {
			_mapObjectsController.addPlayerTank(_tankController.tank);
		}

		private function addListeners():void {
			_mouseDrawController.addEventListener(DrawingControllerEvent.WANT_START_DRAW, onWantStartDraw);
			_mouseDrawController.addEventListener(DrawingControllerEvent.NEW_MOVE_POINT, onNewMovePoint);
			_mouseDrawController.addEventListener(DrawingControllerEvent.DRAWING_COMPLETE, onDrawingComplete);
			_mapObjectsController.addEventListener(MineBamEvent.BAM, onMineBam);
			_mapObjectsController.addEventListener(DamageObjectEvent.DAMAGE_PLAYER_TANK, onPlayerDamage);
			_mapObjectsController.addEventListener(GameBonusEvent.BONUS_APPLY_TO_PLAYER, onApplyBonusToPlayer);
			_tankController.addEventListener(TankShotingEvent.WAS_SHOT, onTankShot);
			_tankController.addEventListener(TankShotingEvent.RELOAD_COMPLETE, onTankReloadComplete);

			_container.addEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown);
			_container.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
			_container.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		
		private function removeListeners():void {
			_mouseDrawController.removeEventListener(DrawingControllerEvent.WANT_START_DRAW, onWantStartDraw);
			_mouseDrawController.removeEventListener(DrawingControllerEvent.NEW_MOVE_POINT, onNewMovePoint);
			_mouseDrawController.removeEventListener(DrawingControllerEvent.DRAWING_COMPLETE, onDrawingComplete);
			_mapObjectsController.removeEventListener(MineBamEvent.BAM, onMineBam);
			_mapObjectsController.removeEventListener(DamageObjectEvent.DAMAGE_PLAYER_TANK, onPlayerDamage);
			_mapObjectsController.removeEventListener(GameBonusEvent.BONUS_APPLY_TO_PLAYER, onApplyBonusToPlayer);
			_tankController.removeEventListener(TankShotingEvent.WAS_SHOT, onTankShot);
			_tankController.removeEventListener(TankShotingEvent.RELOAD_COMPLETE, onTankReloadComplete);

			_container.removeEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown);
			_container.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
			_container.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		
		/* event handlers */
		
		private function onPlayerDamage(event:DamageObjectEvent):void {
			_tankController.tank.tankDamage();
			if(_tankController.tank.isDead()) {
				_tankController.bam();
				_mapObjectsController.targetsController.cleanTargetTank();
				_container.addEventListener(MouseEvent.CLICK, onClick);
			} else {
				_mapObjectsController.dropBonus(GameBonus.MEDKIT);
			}
		}
	  private function onApplyBonusToPlayer(event:GameBonusEvent):void {
			_tankController.applyBonus(event.bonus.type);
		}

		private function onClick(event:MouseEvent):void {
			_container.removeEventListener(MouseEvent.CLICK, onClick);
			dispatchEvent(new SceneEvent(SceneEvent.WANT_REMOVE));
		}
		
		private function onStageMouseDown(event:MouseEvent):void {
			const point:Point = new Point(event.stageX, event.stageY);
			if (!_tankController.isPointOnTank(point) && _tankController.wannaShot) {
				_tankController.setTarget(point);
				_tankController.shot();
				_mouseDown = true;
			}
		}
		private function onStageMouseUp(event:MouseEvent):void {
			_mouseDown = false;
		}
		private function onMouseMove(event:MouseEvent):void {
			_pointUnderMouse.x = event.stageX;
			_pointUnderMouse.y = event.stageY;
			if (_mouseDown && _tankController.wannaShot) {
				_tankController.setTarget(_pointUnderMouse.clone());
				_tankController.shot();
			}
		}

		private function onEnterFrame(event:Event):void {
			if (Math.random() < .4) { _mapObjectsController.checkObjectsInteract(); }
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

		private function onTankReloadComplete(event:TankShotingEvent):void {
			if (_mouseDown && _tankController.wannaShot) {
				_tankController.setTarget(_pointUnderMouse);
				_tankController.shot();
			}
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
		
	}
}
