package game.tank {
	import game.events.GunRotateCompleteEvent;
	import flash.events.EventDispatcher;
	import com.greensock.TweenMax;
	
	import flash.geom.Point;

	public class GunController extends EventDispatcher{
		public var gunRot:int;

		private var _tank:Tank;
		private var _gun:GunView;
		private var _gunLength:Number;
		
		public function GunController(gun:GunView, tank:Tank) {
			_gun = gun;
			_gunLength = _gun.height;
			_tank = tank;
		}
		
		public function removeTween():void {
			TweenMax.killTweensOf(_gun);
		}
		
		public function gunRotation (point:Point):void {
			var angle:int = Math.asin((point.x - _tank.x)/(Math.sqrt((point.x - _tank.x)*(point.x - _tank.x) +
							(point.y - _tank.y)*(point.y - _tank.y))))*180/Math.PI;
			if (point.y < _tank.y) {
				gunRot = angle;
			}
			else {
				//TODO возможно здесь баг с поворотом
				gunRot = 180 - angle;
			}
			TweenMax.to(_gun, 0.4, {rotation : gunRot, onComplete: function():void {
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
	}
}
