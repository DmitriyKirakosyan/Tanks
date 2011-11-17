/**
 * Created by IntelliJ IDEA.
 * User: dima
 * Date: 16/11/11
 * Time: 4:36 PM
 * To change this template use File | Settings | File Templates.
 */
package game.tank {
import com.greensock.TweenMax;
import com.greensock.easing.Linear;

import flash.display.Sprite;

public class BulletEffect {
	private var _bullet:Bullet;
	private var _tailPeriodCounter:int;
	private var _effectType:uint;

	private const TAIL_EFFECT:uint = 0;

	private static const TAIL_PERIOD:int = 1;

	public function BulletEffect(bullet:Bullet, effectType:uint) {
		_tailPeriodCounter = 0;
		_effectType = effectType;
		_bullet = bullet;
	}

	public static function createTailEffect(bullet:Bullet):BulletEffect {
		return new BulletEffect(bullet, TAIL_PERIOD);
	}

	public function updateEffect():void {
		tickTailPeriod();
		if (timeToTail) {
			if (_effectType == TAIL_EFFECT) {
				drawTail();
			}
		}
	}

	/* Internal functions */

	private function drawTail():void {
		if (!_bullet.container) { return; }
		var bulletTailPart:Sprite = new Sprite();
		_bullet.drawBulletPointOn(bulletTailPart);
		bulletTailPart.x = _bullet.x;
		bulletTailPart.y = _bullet.y;
		bulletTailPart.scaleX = bulletTailPart.scaleY = .1;
		bulletTailPart.alpha = .6;
		_bullet.container.addChild(bulletTailPart);
		TweenMax.to(bulletTailPart, 1.5, { scaleX : 3, scaleY : 3, alpha : 0, ease : Linear.easeNone,
									onComplete: function():void { _bullet.container.removeChild(bulletTailPart); } });
	}

	private function tickTailPeriod():void {
		_tailPeriodCounter++;
		if (_tailPeriodCounter >= TAIL_PERIOD) { _tailPeriodCounter = 0; }
	}

	public function get timeToTail():Boolean { return _tailPeriodCounter == 0; }

}
}
