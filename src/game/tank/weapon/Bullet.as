package game.tank.weapon {
import game.IControllerWithTime;
import game.tank.*;

import com.greensock.easing.Linear;

import flash.geom.Point;
import com.greensock.TweenMax;
import flash.display.Sprite;

public class Bullet extends Sprite implements IControllerWithTime {
	private var _tween:TweenMax;
	private var _speed:Number;
	private var _selfTank:Tank;
	private var _type:uint;
	private var _damageStrength:Number;

	private var _bulletEffect:BulletEffect;

	private var _container:Sprite;

	private var speedCoef:Number = 200;

	public static const TAIL_ROCKET_STRENGTH:Number = 8;
	public static const ROCKET_STRENGTH:Number = 5;
	public static const MINIGUN_STRENGTH:Number = .6;

	public static function createTailRocketBullet(selfTank:Tank):Bullet {
		return new Bullet(selfTank,  TankGun.TAIL_ROCKET, TAIL_ROCKET_STRENGTH);
	}
	public static function createMinigunBullet(selfTank:Tank):Bullet {
		return new Bullet(selfTank, TankGun.MINIGUN, MINIGUN_STRENGTH);
	}
	public static function createRocketBullet(selfTank:Tank):Bullet {
		return new Bullet(selfTank, TankGun.ROCKET, ROCKET_STRENGTH);
	}

	public function Bullet(selfTank:Tank, type:uint, damageStrength:Number):void {
		_type = type;
		_damageStrength = damageStrength;
		_selfTank = selfTank;
		_bulletEffect = createBulletEffect();
		drawBulletPointOn(this);
	}

	public function get damageStrength():Number { return _damageStrength; }

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
		if (_bulletEffect) { _bulletEffect.updateEffect(); }
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

	/* time functions */

	public function scaleTime(value:Number):void {
		if (_tween) { _tween.timeScale = value; }
	}

	public function pause():void {
		if (_tween) { _tween.pause(); }
	}
	public function resume():void {
		if (_tween) { _tween.resume(); }
	}

	public function drawBulletPointOn(sprite:Sprite):void {
		var color:uint = _type == TankGun.MINIGUN ? 0xB22222 : 0xf0002f;
		var radius:uint = _type == TankGun.MINIGUN ? 1 : _type == TankGun.TAIL_ROCKET ? 3 : 2;
		sprite.graphics.beginFill(color);
		sprite.graphics.drawCircle(0,0,radius);
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