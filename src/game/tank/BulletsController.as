package game.tank {
	import com.greensock.TweenMax;
	
	import flash.display.Sprite;
	import flash.geom.Point;

	public class BulletsController {
		private var _container:Sprite;
		private var _bullets:Vector.<Bullet>;
		private var _targets:Vector.<Target>;

		public function BulletsController(container:Sprite) {
			_container = container;
			_bullets = new Vector.<Bullet>();
		}
		
		public function addTarget(targets:Vector.<Target>):void {
			_targets = targets;
		}

		public function remove():void {
		 	removeBullets();
		}

		private function getCompleteBulletFunction(bullet:Bullet):Function {
			return function ():void {
				_container.removeChild(bullet);
				removeFromVector(bullet);
			};
		}
		
		private function onBulletTweenUpdate(bullet:Bullet):void {
			for each (var target:Target in _targets) {
				if (bullet.hitTestObject(target) == true){
					removeBulletAndTarget(bullet, target);
				}
			}
		}
		
		private function removeFromVector(bullet:Bullet):void {
			var indexbullet:int = _bullets.indexOf(bullet);
			if (indexbullet != -1) { _bullets.splice(indexbullet, 1); }
		}
		
		private function removeBulletAndTarget(bullet:Bullet, target:Target):void {
			_container.removeChild(bullet);
			killTweenMax(bullet);
			removeFromVector(bullet);
			_container.removeChild(target);
			var indextarget:int = _targets.indexOf(target);
			_targets.splice(indextarget, 1);
		}
		
		private function killTweenMax(bullet:Bullet):void {
			var tweens:Array = TweenMax.getTweensOf(bullet);
			if (tweens && tweens.length > 0) {
				var tween:TweenMax = tweens[0] as TweenMax;
				tween.kill();
			}
		}

		private function removeBullets():void {
			for each (var bullet:Bullet in _bullets) {
				killTweenMax(bullet);
				if (_container.contains(bullet)) { _container.removeChild(bullet); }
			}
		}
/*		
		private function startMove(targetPoint:Point):void {
			startBulletTween(bullet, targetPoint);
		}
	 * 
	 */
	}
}