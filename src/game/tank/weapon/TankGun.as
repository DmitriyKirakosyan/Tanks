/**
 * Created by : Dmitry
 * Date: 11/5/11
 * Time: 1:35 AM
 */
package game.tank.weapon {
import flash.display.Sprite;

public class TankGun extends Sprite{
	private var _type:uint;

	// types
	public static const TAIL_ROCKET:uint = 2;
	public static const ROCKET:uint = 0;
	public static const MINIGUN:uint = 1;

	public function TankGun(weaponType:uint = ROCKET) {
		super();
		_type = weaponType;
		createView();
	}

	public function get type():uint { return _type; }

	/* Internal functions */

	private function createView():void {
		switch (_type) {
			case ROCKET :
				this.addChild(new GunView());
				break;
			case MINIGUN :
				createMiniGun();
				break;
			default : //TAIL_ROCKET
				createTailRocket();
		}
	}

	private function createMiniGun():void {
		this.addChild(new MiniGun());
	}
	private function createTailRocket():void {
		this.addChild(new RocketGun());
	}

}
}
