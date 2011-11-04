/**
 * Created by : Dmitry
 * Date: 11/5/11
 * Time: 1:35 AM
 */
package game.tank {
import flash.display.Sprite;

public class TankGun extends Sprite{
	private var _type:uint;

	public static const ROCKET:uint = 0;
	public static const MINIGUN:uint = 1;
	public static const FIREGUN:uint = 2;

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
				createMinigun();
				break;
			default : //FIREGUN
				createFiregun();
		}
	}

	private function createMinigun():void {
		this.graphics.lineStyle(2, 0x00000a);
		this.graphics.lineTo(-3, -10);
		this.graphics.moveTo(0, 0);
		this.graphics.lineTo(0, -10);
		this.graphics.moveTo(0, 0);
		this.graphics.lineTo(3, -10);
	}
	private function createFiregun():void {
		this.graphics.beginFill(0xa11717);
		this.graphics.drawRect(-5, -20, 10, 20);
		this.graphics.endFill();
	}

}
}
