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

import game.events.TankEvent;

import game.matrix.MapMatrix;

public class TankBotController extends TankController{
	private var _targetTank:Tank;

	public function TankBotController(container:Sprite, mapMatrix:MapMatrix) {
		super(container, mapMatrix);
	}

	override public function setTargetTank(targetTank:Tank):void {
		_targetTank = targetTank;
		if (!this.hasEventListener(TankEvent.COME_TO_CELL)) {
			this.addEventListener(TankEvent.COME_TO_CELL, onTankComeToCell);
		}
	}

	private function onTankComeToCell(event:TankEvent):void {
		if (!_targetTank) { return; }
		if (_targetTank.x == tank.x || _targetTank.y == tank.y) {
			setTarget(new Point(_targetTank.x,  _targetTank.y));
			shot();
		}

	}

	private function onAutoAttackTimer(event:TimerEvent):void {
		if (_targetTank) {
			setTarget(new Point(_targetTank.originX, _targetTank.originY));
		}
	}

}
}
