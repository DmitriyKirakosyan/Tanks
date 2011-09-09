package game.mapObjects {
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import game.MapObject;

	public class Brick extends MapObject {
		private var _damaged:Boolean;
		
		public function Brick(point:Point) {
			_damaged = false;
			this.x = point.x;
			this.y = point.y;
			const brick:BricksView = new BricksView();
			this.addChild(brick);
		}
		
		public function damage():void {
			_damaged = true;
			const damagedBrick:DamagedBriksView = new DamagedBriksView();
			this.addChild(damagedBrick);
		}
		
		public function get damaged():Boolean { return _damaged; }
	}
}
