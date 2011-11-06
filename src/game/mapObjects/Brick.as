package game.mapObjects {
	import flash.geom.Point;

	import game.MapObject;

	public class Brick extends MapObject {
		private var _damaged:Boolean;
		
		public function Brick(point:Point) {
			super();
			_damaged = false;
			this.x = point.x;
			this.y = point.y;
			const brick:BricksView = new BricksView();
			brick.x -= brick.width/2;
			brick.y -= brick.height/2;
			this.addChild(brick);
		}
		
		public function damage():void {
			_damaged = true;
			const damagedBrick:DamagedBriksView = new DamagedBriksView();
			damagedBrick.x = -damagedBrick.width/2;
			damagedBrick.y = -damagedBrick.height/2;
			this.addChild(damagedBrick);
		}
		
		public function get damaged():Boolean { return _damaged; }
	}
}
