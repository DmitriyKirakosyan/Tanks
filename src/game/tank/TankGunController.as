package game.tank {
	import game.events.GunRotateCompleteEvent;
	import flash.events.EventDispatcher;
	import com.greensock.TweenMax;
	
	import flash.geom.Point;

	public class TankGunController extends EventDispatcher{
		public var gunRot:int;

		private var _type:uint;

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
		}

		public function get gun():TankGun { return _gun; }

		public function updateGun(type:uint):void {
			TweenMax.killTweensOf(_gun);
			_gun = new TankGun(type);
		}

		public function killGunTweens():void {
			TweenMax.killTweensOf(_gun);
		}

		public function get rotating():Boolean { return _rotating; }
		
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
			switch (_type) {
				case TankGun.TAIL_ROCKET : return Bullet.createTailRocketBullet(_tank);
				case TankGun.MINIGUN : return Bullet.createMinigunBullet(_tank);
			}
			return Bullet.createRocketBullet(_tank);
		}
	}
}
