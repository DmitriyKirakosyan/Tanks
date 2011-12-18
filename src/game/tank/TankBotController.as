/**
 * User: dima
 * Date: 30/11/11
 * Time: 5:01 PM
 */
package game.tank {
import flash.display.Sprite;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flash.utils.Timer;

import game.GameController;
import game.events.TankDestructionEvent;

import game.events.TankEvent;

import game.matrix.MapMatrix;

public class TankBotController extends TankController{
	private var _targetTank:Tank;
	private var _strength:uint;

	private var _waitTimer:Timer;

	private const UPDATE_FRAME_PERIOD:int = 10;
	private var _currentUpdateCounter:int;

	public static const BASE_BOT:uint = 0;
	public static const ADVANCE_BOT:uint = 1;
	public static const HARD_BOT:uint = 2;

	public function TankBotController(container:Sprite, mapMatrix:MapMatrix, strength:uint = BASE_BOT) {
		super(container, mapMatrix);
		_currentUpdateCounter = 0;
		_strength = strength;
		_waitTimer = new Timer(3000);
	}

	override public function init(tankVO:TankVO):void {
		super.init(tankVO);
		if (_strength != BASE_BOT) {
			tank.filters = _strength == ADVANCE_BOT ? [new GlowFilter()] : [new GlowFilter(0)];
		}
	}

	override public function remove():void {
		super.remove();
		tank.removeEventListener(Event.ENTER_FRAME, onTankEnterFrame);
	}

	public function get strength():uint { return _strength; }

	override protected function createTank(tankVO:TankVO):void {
		tank = Tank.createBotTank(tankVO, _strength);
	}

	public function setTargetTank(targetTank:Tank):void {
		_targetTank = targetTank;
		if (!this.hasEventListener(TankEvent.COME_TO_CELL)) {
			tank.addEventListener(Event.ENTER_FRAME, onTankEnterFrame);
		}
	}

	public function removeTargetTank():void {
		if (_targetTank) {
			_targetTank = null;
			tank.removeEventListener(Event.ENTER_FRAME, onTankEnterFrame);
		}
	}

	public function getTargetMovePoint():Point {
		if (!_targetTank) { return null; }
		if (_strength > 1 && Math.abs(_targetTank.x - tank.x) < GameController.CELL * 5 &&
						Math.abs(_targetTank.y - tank.y) < GameController.CELL * 5) {
			return new Point(_targetTank.x,  _targetTank.y);
		}
		return null;
	}

	public function hasTargetTank():Boolean { return _targetTank != null; }

	public function standHere():void {
		onMovingComplete();
	}

	override protected function onTankDestroyed(event:TankDestructionEvent):void {
		super.onTankDestroyed(event);
		tank.removeEventListener(Event.ENTER_FRAME, onTankEnterFrame);
	}

	private function onTankEnterFrame(event:Event):void {
		if (_currentUpdateCounter >= UPDATE_FRAME_PERIOD) {
			updateTankThink();
			_currentUpdateCounter = 0;
		} else { _currentUpdateCounter++; }
	}

	private function updateTankThink():void {
		if (!_targetTank || !this.wannaShot) { return; }
		if (Math.abs(_targetTank.originX - tank.originX) < GameController.CELL ||
				Math.abs(_targetTank.originY - tank.originY) < GameController.CELL) {
			setTarget(new Point(_targetTank.originX,  _targetTank.originY));
			shot();
		}
		if (_strength == 0) { return; }
		var xDistance:Number = Math.abs(_targetTank.originX - tank.originX);
		var yDistance:Number = Math.abs(_targetTank.originY - tank.originY);
		if (xDistance < GameController.CELL*3) {
				if (_targetTank.originX < tank.originX && _targetTank.baseRotation == TankController.RIGHT_ROT) {
					setTarget(new Point(_targetTank.originX + xDistance,  _targetTank.originY));
					shot();
				} else if (_targetTank.originX > tank.originX && _targetTank.baseRotation == TankController.LEFT_ROT) {
					setTarget(new Point(_targetTank.originX - xDistance,  _targetTank.originY));
					shot();
				}
		}
		if (yDistance < GameController.CELL*3) {
			if (_targetTank.originY < tank.originY && (_targetTank.baseRotation == TankController.DOWN_ROT_MINUS || _targetTank.baseRotation == TankController.DOWN_ROT_PLUS)) {
					setTarget(new Point(_targetTank.originX,  _targetTank.originY + yDistance));
					shot();
			} else if (_targetTank.originY > tank.originY && _targetTank.baseRotation == TankController.UP_ROT) {
					setTarget(new Point(_targetTank.originX,  _targetTank.originY - yDistance));
					shot();
			}
		}
	}

	override protected function onMovingComplete():void {
		_waitTimer.addEventListener(TimerEvent.TIMER, onWaitTimer);
		_waitTimer.start();
	}

	private function onWaitTimer(event:TimerEvent):void {
		_waitTimer.removeEventListener(TimerEvent.TIMER, onWaitTimer);
		_waitTimer.stop();
//		tank.correctMapPosition();
		super.onMovingComplete();
	}

	private function onAutoAttackTimer(event:TimerEvent):void {
		if (_targetTank) {
			setTarget(new Point(_targetTank.originX, _targetTank.originY));
		}
	}

}
}
