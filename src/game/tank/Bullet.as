package game.tank {
	import flash.geom.Point;
	import com.greensock.TweenMax;
	import flash.display.Sprite;
	
	public class Bullet extends Sprite {
		private var _tween:TweenMax;
		private var _speed:Number;
		private var _selfTank:Tank;
		
		public function Bullet(selfTank:Tank, stagePoint:Point):void {
			var view:BulletView = new BulletView();
			_selfTank = selfTank;
			addChild(view);
			this.rotation = selfTank.gunController.gunRot;
			const bulletPoint:Point = selfTank.gunController.getBulletPoint(stagePoint);
			this.x = bulletPoint.x;
			this.y = bulletPoint.y;
		}
		
		public function get selfTank():Tank { return _selfTank; }
		
		public function moveTo(point:Point):void {
			_speed = Math.sqrt(Math.pow(this.x-point.x, 2) + Math.pow(this.y - point.y, 2)) / 200;
			trace(_speed);
			_tween = new TweenMax(this, _speed, {x : point.x, y : point.y
																//onUpdate : onBulletTweenUpdate,
																//onUpdateParams : [bullet],
																//onComplete : getCompleteBulletFunction(bullet)
																} );
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
		
	}
}