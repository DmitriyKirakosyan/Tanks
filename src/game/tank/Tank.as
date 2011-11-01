package game.tank {
import com.greensock.TimelineMax;
import com.greensock.TweenMax;

import flash.display.Sprite;
import flash.geom.ColorTransform;
import flash.geom.Point;

import game.GameController;
import game.MapObject;

	public class Tank extends MapObject {
		public var gun:GunView;
		public var tankBase:Sprite;
		public var gunController:GunController;

		private var _vo:TankVO;

        private var _destroyMethod:TankDestroyMethod;

		private var _player:Boolean;
		
		private var _speedup:Number = 0;
		private var maxSpeedup:Number = .5;


		public var liveTab:LiveTab;

		public function Tank(vo:TankVO, player:Boolean = false) {
			_player = player;
			gun = new GunView();
			_vo = vo;

            _destroyMethod = new TankDestoryRotation(this);
			
			liveTab = new LiveTab();
			this.addChild(liveTab);
			
			if (vo.tankBase == 0) {
				tankBase = new TankBaseView();
			} else {
				tankBase = new Sprite();
				const brickView:BricksView = new BricksView();
				brickView.x -= brickView.width/2; brickView.y -= brickView.height/2;
				tankBase.addChild(brickView);
			}
			this.addChild(tankBase);
			this.addChild(gun);
			gunController = new GunController(gun, this);
		}
		
		public function tankDamage():void{
			this.liveTab.scaleX -= .5;
		}
		
		public function updateLive():void {
			this.liveTab.scaleX = 1;
		}

		public function get vo():TankVO { return _vo; }

		public function remove():void {
			if (this.contains(tankBase)) this.addChild(tankBase);
			if (this.contains(gun)) this.addChild(gun);
		}
		
		public function bam():void {
			_destroyMethod = TankDestroyMethodFactory.createRandomMethod(this);
			_destroyMethod.addEventListener(TankDestoryEvent.DESTORY_COMPLETE, onDestroyComplete);
			_destroyMethod.destroy();
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

		/* Internal functions */

		private function onDestroyComplete(event:TankDestoryEvent):void {
			trace("[Tank.onDestroyComplete] me destroed");
		}

		
	}
}