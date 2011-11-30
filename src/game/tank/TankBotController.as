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

import game.matrix.MapMatrix;

public class TankBotController extends TankController{
	private var _autoAttackTimer:Timer;
	private var _targetTank:Tank; //for autoattack mode only

	public function TankBotController(container:Sprite, mapMatrix:MapMatrix) {
		super(container, mapMatrix);
	}

	public function get autoAttackTimer():Timer { return _autoAttackTimer; }

	override public function setAutoAttack(targetTank:Tank):void {
		_targetTank = targetTank;
		_autoAttackTimer = new Timer(Math.random() * 5000 + 1000);  //TODO Auto attack
		_autoAttackTimer.addEventListener(TimerEvent.TIMER, onAutoAttackTimer);
		_autoAttackTimer.start();
	}

	override public function remove():void {
		super.remove();
		if (_autoAttackTimer && _autoAttackTimer.running) { _autoAttackTimer.stop(); }
	}

	override public function bam():void {
		if (_autoAttackTimer) { _autoAttackTimer.stop(); }
	}

	private function onAutoAttackTimer(event:TimerEvent):void {
		if (_targetTank) {
			setTarget(new Point(_targetTank.originX, _targetTank.originY));
		}
	}

}
}
