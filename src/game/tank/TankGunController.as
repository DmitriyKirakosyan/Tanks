package game.tank {
import game.IControllerWithTime;
import game.events.GunRotateCompleteEvent;
	import flash.events.EventDispatcher;
	import com.greensock.TweenMax;
	
	import flash.geom.Point;

	public class TankGunController extends EventDispatcher implements IControllerWithTime {
		public var gunRot:int;

		private var _type:uint;

		private var _reloadController:GunReloadController;

		private var _rotating:Boolean;

		private var _tank:Tank;
		private var _gun:TankGun;
		private var _gunLength:Number;
		
		public function TankGunController(type:uint, tank:Tank) {
			_gun = gun;
			_type = type;
			_gunLength = _gun.height;
			_tank = tank;
			_gun = new TankGun(type);
			_reloadController = new GunReloadController(reloadSpeed);
			_reloadController.reloadBar.y = tank.originY + 30;
			_reloadController.reloadBar.x = tank.originX - tank.width/2;
		}

		public function scaleTime(value:Number):void {
			if (_reloadController.reloading) {
				_reloadController.scaleTime(value);
			}
		}

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
		
		public function rotateGun (point:Point):void {
			var angle:int = Math.asin((point.x - _tank.x)/(Math.sqrt((point.x - _tank.x)*(point.x - _tank.x) +
							(point.y - _tank.y)*(point.y - _tank.y))))*180/Math.PI;
			if (point.y < _tank.y) {
				gunRot = angle;
			}
			else {
				//TODO возможно здесь баг с поворотом
				gunRot = 180 - angle;
			}
			_rotating = true;
			TweenMax.to(_gun, 0.4, {rotation : gunRot, onComplete: function():void {
					_rotating = false;
					dispatchEvent(new GunRotateCompleteEvent(GunRotateCompleteEvent.COMPLETE));
				}
			});
		}
		
		private function getBulletPoint():Point {
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

		private function get reloadSpeed():Number {
			return _type == TankGun.MINIGUN ? 10 : _type == TankGun.TAIL_ROCKET ? 2 : 4;
		}
	}
}
