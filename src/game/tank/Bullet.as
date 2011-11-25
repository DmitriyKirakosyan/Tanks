package game.tank {
import com.greensock.easing.Linear;

import flash.geom.Point;
import com.greensock.TweenMax;
import flash.display.Sprite;

public class Bullet extends Sprite {
	private var _tween:TweenMax;
	private var _speed:Number;
	private var _selfTank:Tank;
	private var _type:uint;

	private var _bulletEffect:BulletEffect;

	private var _container:Sprite;

	private var speedCoef:Number = 200;

	public static function createTailRocketBullet(selfTank:Tank):Bullet {
		return new Bullet(selfTank,  TankGun.TAIL_ROCKET);
	}
	public static function createMinigunBullet(selfTank:Tank):Bullet {
		return new Bullet(selfTank, TankGun.MINIGUN);
	}
	public static function createRocketBullet(selfTank:Tank):Bullet {
		return new Bullet(selfTank);
	}

	public function Bullet(selfTank:Tank, type:uint = TankGun.ROCKET):void {
		_type = type;
		_selfTank = selfTank;
		_bulletEffect = createBulletEffect();
		drawBulletPointOn(this, 0xf0002f);
	}

	public function setPosition(point:Point):void {
		this.x = point.x;
		this.y = point.y;
	}

	public function get container():Sprite { return _container; }

	public function get selfTank():Tank { return _selfTank; }

	public function setContainer(container:Sprite):void {
		_container = container;
	}

	public function updateEffect():void {
		_bulletEffect.updateEffect();
	}

	public function moveTo(point:Point):void {
		if (_selfTank.isPlayer) { speedCoef = 200; }
		else { speedCoef = 100; }
		_speed = Math.sqrt(Math.pow(this.x-point.x, 2) + Math.pow(this.y - point.y, 2)) / speedCoef;
		_tween = new TweenMax(this, _speed, {x : point.x, y : point.y, ease : Linear.easeNone} );
	}

	public function remove():void {
		_tween.vars["onComplete"] = null;
		_tween.vars["onUpdate"] = null;
		_tween.kill();
	}

	public function onComplete(onComplete:Function):void {
		if (_tween) {
			_tween.vars["onComplete"] = onComplete;
			_tween.vars["onCompleteParams"] = [this];
		}
	}

	public function onUpdate(onUpdate:Function):void {
		if (_tween) {
			_tween.vars["onUpdate"] = onUpdate;
			_tween.vars["onUpdateParams"] = [this];
		}
	}

	public function scaleTime(value:Number):void {
		if (_tween) { _tween.timeScale = value; }
	}

	public function drawBulletPointOn(sprite:Sprite, color:uint = 0x0fafcd):void {
		sprite.graphics.beginFill(color);
		sprite.graphics.drawCircle(0,0,2);
		sprite.graphics.endFill();
	}

	/* Internal functions */

	private function createBulletEffect():BulletEffect {
		if (_type == TankGun.TAIL_ROCKET) { return BulletEffect.createRocketTailEffect(this);
		} else if (_type == TankGun.MINIGUN) { return BulletEffect.createMinigunTailEffect(this); }

		return null;
	}
}
}