/**
 * User: dima
 * Date: 8/12/11
 * Time: 3:17 PM
 */
package game.drawing {
import flash.display.Sprite;

public class PathShape extends Sprite{
	public static const CIRCLE:uint = 0;
	public static const RECTANGLE:uint = 1;

	private var _type:uint;

	public static function createCircleShape():PathShape {
		return new PathShape(CIRCLE);
	}
	public static function createRectangleShape():PathShape {
		return new PathShape(RECTANGLE);
	}

	public function PathShape(type:uint) {
		_type = type;
		draw();
	}

	private function draw():void {
		this.graphics.beginFill(0xffffff);
		if (_type == RECTANGLE) {
			this.graphics.drawRect(-3, -3, 6, 6);
		} else { this.graphics.drawCircle(0, 0, 2); }
		this.graphics.endFill();
	}
}
}
