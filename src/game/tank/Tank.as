package game.tank {
	import game.MapObject;
	import com.greensock.TweenMax;

import flash.geom.ColorTransform;

import game.GameController;
	import flash.display.Sprite;

	public class Tank extends MapObject {
		public var gun:GunView;
		public var tankBase:TankBaseView;
		public var gunController:GunController;

        private var _player:Boolean;
		
		private var _speedup:Number = 0;
		private var maxSpeedup:Number = .5;
		
		public function Tank(player:Boolean = false) {
			_player = player;
			gun = new GunView();
			tankBase = new TankBaseView();
			this.addChild(gun);
			this.addChild(tankBase);
			if (!_player) {
				const colorInfo:ColorTransform = new ColorTransform();
				colorInfo.color = 0x941aff;
				this.transform.colorTransform = colorInfo;
			}
			gunController = new GunController(gun, this);
		}
		
		public function bam():void {
			TweenMax.to(tankBase, 2, {x : tankBase.x + Math.random()*80-40,
																y : tankBase.y + Math.random()*80-40,
																rotation : tankBase.rotation + Math.random()*100});
			TweenMax.to(gun, 1.5, {x : gun.x + Math.random()*400-200,
															y : tankBase.y + Math.random()*400-200,
															rotation : tankBase.rotation + Math.random()*300});
		}
		
		public function set speedup(value:Number):void {
			if (_speedup < maxSpeedup) { _speedup+= .05; }
		}
		public function get speedup():Number { return _speedup; }
		
		public function updateSpeedup():void { _speedup = 0; }

		
		override public function set x(value:Number):void {
			super.x = value * GameController.CELL + GameController.CELL/2;
		}
		override public function set y(value:Number):void {
			super.y = value * GameController.CELL + GameController.CELL/2;
		}
		override public function get x():Number { return (super.x - GameController.CELL/2) / GameController.CELL;}
		override public function get y():Number { return (super.y - GameController.CELL/2) / GameController.CELL; }
		
		public function get stageX():Number { return super.x; }
		public function get stageY():Number { return super.y; }
	}
}