/**
 * User: dima
 * Date: 28/11/11
 * Time: 2:59 PM
 */
package game.tank {
import flash.display.Sprite;

public class TankDefense extends Sprite {
	private var _type:uint;

	public static const TIME_DEFENSE:uint = 0;

	public static function createTimeDefense():TankDefense {
		return new TankDefense(TIME_DEFENSE);
	}

	public function TankDefense(type:uint) {
		super();
		_type = type;
		draw();
	}

	public function get type():uint { return _type; }

	private function draw():void {
		if (_type == TIME_DEFENSE) { drawTimeDefense();
		} else { drawDefault(); }
	}

	private function drawDefault():void {
		this.graphics.beginFill(0, .5);
		this.graphics.drawRect(-25, -25, 50, 50);
		this.graphics.endFill();
	}

	private function drawTimeDefense():void {
		this.graphics.beginFill(0, .2);
		this.graphics.drawCircle(0, 0, 100);
		this.graphics.endFill();
	}
}
}
