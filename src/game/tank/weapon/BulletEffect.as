/**
 * Created by IntelliJ IDEA.
 * User: dima
 * Date: 16/11/11
 * Time: 4:36 PM
 * To change this template use File | Settings | File Templates.
 */
package game.tank.weapon {
import com.greensock.TweenMax;
import com.greensock.easing.Linear;

import flash.display.Sprite;

import game.tank.weapon.Bullet;

public class BulletEffect {
	private var _bullet:Bullet;
	private var _tailPeriodCounter:int;
	private var _tailPeriod:int;
	private var _effectType:uint;

	private static const ROCKET_TAIL_EFFECT:uint = 0;
	private static const MINIGUN_TAIL_EFFECT:uint = 1;

	public function BulletEffect(bullet:Bullet, effectType:uint) {
		_tailPeriodCounter = 0;
		_tailPeriod = effectType == ROCKET_TAIL_EFFECT ? 1 : 3;
		_effectType = effectType;
		_bullet = bullet;
	}

	public static function createRocketTailEffect(bullet:Bullet):BulletEffect {
		return new BulletEffect(bullet, ROCKET_TAIL_EFFECT);
	}

	public static function createMinigunTailEffect(bullet:Bullet):BulletEffect {
		return new BulletEffect(bullet, MINIGUN_TAIL_EFFECT);
	}

	public function updateEffect():void {
		tickTailPeriod();
		if (timeToTail) {
			if (_effectType == ROCKET_TAIL_EFFECT) {
				drawTail();
			} else if (_effectType == MINIGUN_TAIL_EFFECT) {
				drawMinigunTail();
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

	private function drawMinigunTail():void {
		if (!_bullet.container) { return; }
		var bulletTailPart:Sprite = new Sprite();
		bulletTailPart.graphics.lineStyle(1, 0x0fafaf);
		bulletTailPart.graphics.lineTo(0, -10);
		bulletTailPart.rotation = _bullet.rotation + 180;
		bulletTailPart.x = _bullet.x;
		bulletTailPart.y = _bullet.y;
		bulletTailPart.alpha = .6;
		_bullet.container.addChild(bulletTailPart);
		TweenMax.to(bulletTailPart, 1.5, { alpha : 0, ease : Linear.easeNone,
									onComplete: function():void { _bullet.container.removeChild(bulletTailPart); } });
	}

	private function tickTailPeriod():void {
		_tailPeriodCounter++;
		if (_tailPeriodCounter >= _tailPeriod) { _tailPeriodCounter = 0; }
	}

	public function get timeToTail():Boolean { return _tailPeriodCounter == 0; }

}
}
