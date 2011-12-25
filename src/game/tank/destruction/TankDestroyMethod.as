/**
 * User: dima
 * Date: 1/11/11
 * Time: 5:05 PM
 */
package game.tank.destruction {
import game.tank.*;

import flash.events.EventDispatcher;

public class TankDestroyMethod extends EventDispatcher{
	private var _tank:Tank;

	public function TankDestroyMethod(tank:Tank):void {
			_tank = tank;
	}

	public function stopDestroying():void {}
	public function get tank():Tank { return _tank; }

	public function destroy():void {}

}
}
