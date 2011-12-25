package game.tank.weapon {
import game.tank.*;

import flash.events.Event;

import game.IControllerWithTime;
import game.events.GunRotateCompleteEvent;
import flash.events.EventDispatcher;
import com.greensock.TweenMax;

import flash.geom.Point;

public class TankGunController extends EventDispatcher implements IControllerWithTime {
	private var _type:uint;

	private var _reloadController:GunReloadController;

	private var _rotating:Boolean;

	private var _tank:Tank;
	private var _gun:TankGun;
	private var _gunLength:Number;
	private var _rotationCoeff:int;
	private var _targetRotation:Number;


	private var _gunSpeed:Number = 4;

	public function TankGunController(tank:Tank) {
		_tank = tank;
		if (!tank) {
			throw new Error("where is my tank?? [TankGunController]");
		}
		_type = tank.vo.weaponType;
		_gunSpeed = _type == TankGun.MINIGUN ? 7 : _type == TankGun.ROCKET ? 5 : 3;
		_gun = tank.gun;
		_gunLength = _gun.height;
		_reloadController = new GunReloadController(getReloadSpeed());
		_reloadController.reloadBar.y = tank.originY + 30;
		_reloadController.reloadBar.x = tank.originX - tank.width/2;
	}

	/* time functinos */

	public function scaleTime(value:Number):void {
		if (_reloadController.reloading) {
			trace("reload controller speed down [TankGunController.scaleTime]");
			_reloadController.scaleTime(value);
		}
	}

	public function pause():void {
		if (_reloadController.reloading) {
			_reloadController.pause();
		}
	}
	public function resume():void {
		if (_reloadController.reloading) {
			_reloadController.resume();
		}
	}
	public function get targetRotation():Number { return _targetRotation; }
	public function get rotating():Boolean { return _rotating; }
	public function get gun():TankGun { return _gun; }
	public function get reloadController():GunReloadController { return _reloadController; }

	public function updateGun(type:uint):void {
		TweenMax.killTweensOf(_gun);
		_gun = new TankGun(type);
	}

	public function killGunTweens():void {
		TweenMax.killTweensOf(_gun);
	}


	public function removeTween():void {
		TweenMax.killTweensOf(_gun);
	}

	public function rotateGun(point:Point):void {
		var angle:Number = getAngleByPoint(point);
		_rotationCoeff = getCoeffForAngle(angle);
		_targetRotation = angle > 180 ? angle - 360 : angle;
		if (Math.abs(_gun.rotation - _targetRotation) < 5 ||
				Math.abs(_gun.rotation - _targetRotation) > 355) {
			_gun.rotation = _targetRotation;
		} else {
			startRotating();
		}
	}

	private function startRotating():void {
		_rotating = true;
		_gun.addEventListener(Event.ENTER_FRAME, onGunEnterFrame);
	}
	private function stopRotating():void {
		_rotating = false;
		_gun.removeEventListener(Event.ENTER_FRAME, onGunEnterFrame);
		dispatchEvent(new GunRotateCompleteEvent(GunRotateCompleteEvent.COMPLETE));
	}

	private function onGunEnterFrame(event:Event):void {
		if (Math.abs(_targetRotation - _gun.rotation) <= _gunSpeed) {
			stopRotating();
			return;
		}
		_gun.rotation += _rotationCoeff * _gunSpeed;
	}

	private function getCoeffForAngle(angle:Number):int {
		var selfRotation:Number = _gun.rotation;
		var newRotation:Number = angle;

		if (selfRotation < 0) { selfRotation = 360 + selfRotation; }
		var selfMore:Boolean = selfRotation > newRotation;
		if (selfMore) { newRotation += 180; } else { selfRotation += 180; }
		return ((selfMore && newRotation > selfRotation) ||
						(!selfMore && selfRotation > newRotation))? selfMore ? -1 : 1 : selfMore ? 1 : -1;
	}

	private function getAngleByPoint(point:Point):Number {
		var result:Number = Math.atan(-(point.y-_tank.y)/(point.x-_tank.x)) * 180 / Math.PI;
		if (point.x >= _tank.x) {
			result = 90 - result;
		} else {
			result = 270 - result;
		}
		return result;
	}

	public function getBulletPoint():Point {
		var angle:Number = (-_gun.rotation + 90);
		var endX:Number = Math.cos(angle/180 * Math.PI) * _gunLength;
		var endY:Number = -Math.sin(angle/180 * Math.PI) * _gunLength;
		return new Point(_tank.originX + endX, _tank.originY + endY);
	}

	public function updateWeaponType(type:uint):void {
		if (_type != type) {
			_type = type;
			updateGun(type);
		}
	}

	public function createBullet():Bullet {
		var result:Bullet;
		switch (_type) {
			case TankGun.TAIL_ROCKET : result = Bullet.createTailRocketBullet(_tank); break;
			case TankGun.MINIGUN : result = Bullet.createMinigunBullet(_tank); break;

			default : result = Bullet.createRocketBullet(_tank);
		}
		result.setPosition(getBulletPoint());
		result.rotation = _gun.rotation;
		return result;
	}

	private function getReloadSpeed():Number {
		return _type == TankGun.MINIGUN ? 9 : _type == TankGun.TAIL_ROCKET ? .5 : 1;
	}

}
}
