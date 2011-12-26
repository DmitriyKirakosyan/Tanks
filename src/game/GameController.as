package game {
import com.bit101.components.Text;

import flash.events.Event;
import flash.events.TimerEvent;
import flash.filters.BlurFilter;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.utils.Timer;

import game.Debug.DebugController;
import game.events.DamageObjectEvent;
import game.events.GameBonusEvent;
import game.events.SceneEvent;
import game.mapObjects.MapEditor;
import game.mapObjects.bonus.GameBonus;
import game.tank.PlayerTankController;
import game.tank.Tank;
import game.tank.TankBotController;
import game.tank.TankMovementListener;
import game.tank.TankVO;
import game.tank.ability.TankAbility;

import mochi.as3.MochiAd;

import mochi.as3.MochiDigits;
import mochi.as3.MochiScores;
import mochi.as3.MochiServices;

import pathfinder.Pathfinder;
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
	var o:Object = { n: [8, 9, 5, 0, 10, 7, 8, 2, 5, 14, 10, 6, 8, 8, 8, 1],
		f: function (i:Number,s:String):String { if (s.length == 16) return s; return this.f(i+1,s + this.n[i].toString(16));}};
	var boardID:String = o.f(0,"");

	private var _container:Sprite;
	private var _mapEditor:MapEditor;
	private var _tankController:PlayerTankController;
	private var _tankMovementListener:TankMovementListener;
	private var _mapMatrix:MapMatrix;
	private var _mapObjectsController:MapObjectsController;
	private var _mouseDrawController:MouseDrawController;
	private var _timeController:TimeController;
	//private var _debugController:DebugController;
	private var _mouseDown:Boolean;
	private var _endWindow:EndGameWindow;

	private var _pointUnderMouse:Point;

	public static const CELL:int = 40;

	public function GameController(container:Sprite):void {
		_mouseDown = false;
		_container = container;
		_pointUnderMouse = new Point();
		initControllers();
	}

	public function open():void {
		UserState.instance.clearScore();
		_mapObjectsController.init(); // first of all we need to create map and map objects
		_tankController.init(UserState.instance.tankVO);
		initMapObjectsController();
		addListeners();
		//_debugController.open();
	}

	public function remove():void {
		removeListeners();
		_mapMatrix.remove();
		_mouseDrawController.remove();
		_tankController.remove();
		_mapObjectsController.remove();
		//_debugController.close();
		_mouseDown = false;
	}

	/* For debug */

	public function get mapObjectsController():MapObjectsController { return _mapObjectsController; }
	public function get mapEditor():MapEditor { return _mapEditor; }
	public function get targetsController():TargetsController { return _mapObjectsController.targetsController; }
	public function get container():Sprite { return _container; }
	public function get playerTankController():TankController { return _tankController; }
	public function get timeController():TimeController { return _timeController; }

	public function startNewGame():void {
		remove();
		open();
	}

	/* Inits */

	private function initControllers():void {
		_mapMatrix = new MapMatrix(_container);
		_mapMatrix.drawMatrix();
		Pathfinder.setMatrix(_mapMatrix.matrix);
		_mouseDrawController = new MouseDrawController(_container, _mapMatrix);
		trace("[GameController.initControllers] tank base : ", UserState.instance.tankVO.tankBase);
		_tankController = new PlayerTankController(_container, _mapMatrix);
		_mapObjectsController = new MapObjectsController(_mapMatrix, _container);
		_tankMovementListener = new TankMovementListener(_tankController, _mapObjectsController, _mouseDrawController);
		_timeController = new TimeController(_container);
		//_debugController = new DebugController(_container, this);
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
		_container.addEventListener(MouseEvent.ROLL_OUT, onContainerMouseOut);
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
		_container.removeEventListener(MouseEvent.ROLL_OUT, onContainerMouseOut);
	}

	/* event handlers */

	private function onPlayerDamage(event:DamageObjectEvent):void {
		_tankController.tank.damage(event.damageValue);
		if(_tankController.tank.destroyed) {
			_tankController.bam();
			_mapObjectsController.targetsController.cleanTargetTank();
			endGame();
			//showEndWindow();
			//_container.addEventListener(MouseEvent.CLICK, onClick);
		} else {
			_mapObjectsController.dropBonus(GameBonus.MEDKIT);
		}
	}
	private function onApplyBonusToPlayer(event:GameBonusEvent):void {
		_tankController.applyBonus(event.bonus.type);
	}

	private function onClick(event:MouseEvent):void {
		hideEndWindow();
		_container.removeEventListener(MouseEvent.CLICK, onClick);
		dispatchEvent(new SceneEvent(SceneEvent.WANT_REMOVE));
	}

	private function onStageMouseDown(event:MouseEvent):void {
		const point:Point = new Point(event.stageX, event.stageY);
		if (!_tankController.isPointOnTank(point)) {
			if (_tankController.wannaShot) {
				_tankController.setTarget(point);
				_tankController.shot();
			}
			_mouseDown = true;
		}
	}
	private function onStageMouseUp(event:MouseEvent):void {
		_mouseDown = false;
	}
	private function onMouseMove(event:MouseEvent):void {
		_pointUnderMouse.x = event.stageX;
		_pointUnderMouse.y = event.stageY;
		if (_mouseDown) {
			_tankController.setTarget(_pointUnderMouse.clone());
		}
		if (_mouseDown && _tankController.wannaShot) {
			_tankController.shot();
		}
	}

	private function onContainerMouseOut(event:MouseEvent):void {
		timeController.normalize();
		_mouseDrawController.stopDrawing();
	}

	private function onEnterFrame(event:Event):void {
		if (Math.random() < .4) { _mapObjectsController.checkObjectsInteract(); }
	}

	private function onMineBam(event:MineBamEvent):void {
		if (Math.abs(_tankController.tank.x - event.minePoint.x) < event.distantion &&
				Math.abs(_tankController.tank.y - event.minePoint.y) < event.distantion) {
			_tankController.bam();
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
			if (_tankController.tank.ability == TankAbility.TIME_SCALE) {
				_timeController.slowDown();
			}
		}
	}

	private function endGame():void {
		onEndGameTimerComplete(null);
		//var timer:Timer = new Timer(3000, 1);
		//timer.addEventListener(TimerEvent.TIMER, onEndGameTimerComplete);
		//timer.start();
	}
	private function onEndGameTimerComplete(event:TimerEvent):void {
		if (Main.MOCHI_ON) {
			var mochiScore:MochiDigits = new MochiDigits();
			mochiScore.value = UserState.instance.allScore();
			MochiScores.showLeaderboard({
				boardID: boardID,
				score: mochiScore.value,
				onClose: showEndWindow
			});
		} else { showEndWindow(); }
	}

	private function showEndWindow(e:* = null):void {
		if (_endWindow && _container.contains(_endWindow)) {
			_container.removeChild(_endWindow);
		}
		_endWindow = new EndGameWindow();
		_container.addChild(_endWindow);
		_container.addEventListener(MouseEvent.CLICK, onClick);
	}

	private function hideEndWindow():void {
		if (_container.contains(_endWindow)) { _container.removeChild(_endWindow); }

	}

}
}
