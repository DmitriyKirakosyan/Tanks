/**
 * Created by : Dmitry
 * Date: 11/1/11
 * Time: 11:51 PM
 */
package game.tank.destraction {
import game.events.TankDestractionEvent;

import com.greensock.TweenMax;

import game.tank.Tank;

public class TankDestroyFlash extends TankDestroyMethod{

	public function TankDestroyFlash(tank:Tank):void {
		super(tank);
	}

	override public function destroy():void {
	 	TweenMax.to(tank, .5, {scaleX: 2, scaleY: 2, alpha: 0, onComplete: onDestoryComplete });
	}

	private function onDestoryComplete():void {
		dispatchEvent(new TankDestractionEvent(TankDestractionEvent.TANK_DESTRAYED));
	}
}
}
