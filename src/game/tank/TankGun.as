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

	public function TankGun(weaponType:uint) {
		super();
		_type = weaponType;
		createView();
	}

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
		this.graphics.lineTo(-2, -5);
		this.graphics.moveTo(0, 0);
		this.graphics.lineTo(0, -5);
		this.graphics.moveTo(0, 0);
		this.graphics.lineTo(2, -5);
	}
	private function createFiregun():void {
		this.graphics.beginFill(0xa7d7d7);
		this.graphics.drawRect(-5, 0, 10, 10);
		this.graphics.endFill();
	}

}
}
