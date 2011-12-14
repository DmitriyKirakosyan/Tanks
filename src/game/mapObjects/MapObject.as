package game.mapObjects {
import game.*;
	import flash.display.Sprite;

	public class MapObject extends Sprite {
		private var _hp:Number; // -1 -- infinity life

		public function MapObject() {
			super();
			drawRectangle();
		}

		public function damage(value:Number):void {
			_hp -= value;
			if (_hp < 0) { _hp = 0; }
		}

		public function get hp():Number { return _hp; }
		protected function setHp(value:Number):void { _hp = value; }

		override public function set x(value:Number):void {
			super.x = value * GameController.CELL + GameController.CELL/2;
		}
		override public function set y(value:Number):void {
			super.y = value * GameController.CELL + GameController.CELL/2;
		}
		override public function get x():Number { return (super.x - GameController.CELL/2) / GameController.CELL;}
		override public function get y():Number { return (super.y - GameController.CELL/2) / GameController.CELL; }

		public function get originX():Number { return super.x; }
		public function get originY():Number { return super.y; }
		public function set originX(value:Number):void { super.x = value; }
		public function set originY(value:Number):void { super.y = value; }

		public function correctMapPosition():void {
			x = int (x + .5);
			y = int (y + .5);
		}

		private function drawRectangle():void {
			//this.graphics.lineStyle(1, 0xffffff);
			this.graphics.drawRect(-GameController.CELL/2, -GameController.CELL/2, GameController.CELL, GameController.CELL);
		}
	}
}
