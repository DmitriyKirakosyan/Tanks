package game.tank {
import com.greensock.TimelineMax;

import flash.geom.Point;

import game.MapObject;
	import com.greensock.TweenMax;

import flash.geom.ColorTransform;

import game.GameController;
	import flash.display.Sprite;

	public class Tank extends MapObject {
		public var gun:GunView;
		public var tankBase:Sprite;
		public var gunController:GunController;

		private var _vo;

		private var _player:Boolean;
		
		private var _speedup:Number = 0;
		private var maxSpeedup:Number = .5;

		private var _bamTimeline:TimelineMax;
		
		public function Tank(vo:TankVO, player:Boolean = false) {
			_player = player;
			gun = new GunView();
			_vo = vo;
			tankBase = vo.tankBase == 0 ? new TankBaseView() : new BricksView();
			if (!_player) {
				const colorInfo:ColorTransform = new ColorTransform();
				colorInfo.color = 0x941aff;
				this.transform.colorTransform = colorInfo;
			}
			gunController = new GunController(gun, this);
		}

		public function init():void {
			this.addChild(gun);
			this.addChild(tankBase);
		}
		
		public function bam():void {
			_bamTimeline = new TimelineMax({onComplete : onBamComplete});
			_bamTimeline.insert(
				new TweenMax(tankBase, 2, {x : tankBase.x + Math.random()*80-40,
																	y : tankBase.y + Math.random()*80-40,
																	rotation : tankBase.rotation + Math.random()*100})
			);
			_bamTimeline.insert(
				new TweenMax(gun, 1.5, {x : gun.x + Math.random()*400-200,
																y : tankBase.y + Math.random()*400-200,
																rotation : tankBase.rotation + Math.random()*300})
			);
			_bamTimeline.append(
				new TweenMax(this, 1.5, {alpha : 0})
			);
		}

		private function onBamComplete():void {
			this.removeChild(gun);
			this.removeChild(tankBase);
			gun.x = 0; gun.y = 0;
			this.alpha = 1;
			gun.rotation = 0;
			tankBase.x = 0;
			tankBase.y = 0;
			tankBase.rotation = 0;
		}

		public function set speedup(value:Number):void {
			if (_speedup < maxSpeedup) { _speedup+= .05; }
		}
		public function get speedup():Number { return _speedup; }
		
		public function updateSpeedup():void { _speedup = 0; }

		public function killTweens():void {
			TweenMax.killTweensOf(tankBase);
			TweenMax.killTweensOf(gun);
		}

		
	}
}