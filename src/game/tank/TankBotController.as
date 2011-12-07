/**
 * User: dima
 * Date: 30/11/11
 * Time: 5:01 PM
 */
package game.tank {
import flash.display.Sprite;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.utils.Timer;

import game.GameController;

import game.events.TankEvent;

import game.matrix.MapMatrix;

public class TankBotController extends TankController{
	private var _targetTank:Tank;
	private var _strength:uint;

	private const BASE_BOT:uint = 0;
	private const ADVANCE_BOT:uint = 1;

	public function TankBotController(container:Sprite, mapMatrix:MapMatrix, strength:uint = 0) {
		super(container, mapMatrix);
		_strength = strength;
	}

	override public function setTargetTank(targetTank:Tank):void {
		_targetTank = targetTank;
		if (!this.hasEventListener(TankEvent.COME_TO_CELL)) {
			this.addEventListener(TankEvent.COME_TO_CELL, onTankComeToCell);
		}
	}

	override public function removeTargetTank():void {
		if (_targetTank) {
			_targetTank = null;
			this.removeEventListener(TankEvent.COME_TO_CELL, onTankComeToCell);
		}
	}

	public function getTargetMovePoint():Point {
		if (!_targetTank) { return null; }
		if (_strength > 0 && Math.abs(_targetTank.x - tank.x) < GameController.CELL * 5 &&
						Math.abs(_targetTank.y - tank.y) < GameController.CELL * 5) {
			return new Point(_targetTank.x,  _targetTank.y);
		}
		return null;
	}

	override public function hasTargetTank():Boolean { return _targetTank != null; }

	private function onTankComeToCell(event:TankEvent):void {
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

	private function onAutoAttackTimer(event:TimerEvent):void {
		if (_targetTank) {
			setTarget(new Point(_targetTank.originX, _targetTank.originY));
		}
	}

}
}
