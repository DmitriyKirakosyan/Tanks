package game {
	import flash.display.Sprite;

	public class MapObject extends Sprite {
		public function MapObject() {
		}

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
	}
}
