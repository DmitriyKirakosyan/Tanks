package game.mapObjects {
	import flash.geom.Point;

	import game.mapObjects.MapObject;

	public class Brick extends MapObject {
		private var _damagedBrick:DamagedBriksView;

		public function Brick(point:Point) {
			super();
			setHp(ObjectsHp.BRICK);
			this.x = point.x;
			this.y = point.y;
			const brick:BricksView = new BricksView();
			brick.x -= brick.width/2;
			brick.y -= brick.height/2;
			this.addChild(brick);
		}
		
		override public function damage(value:Number):void {
			super.damage(value);
			if (!_damagedBrick) {
				breakBrick();
			}
			_damagedBrick.alpha = 1-hp/maxHp;

		}
		
		public function get damaged():Boolean { return hp < maxHp/2; }

		/* Internal functions */

		private function breakBrick():void {
			_damagedBrick = new DamagedBriksView();
			_damagedBrick.x = -_damagedBrick.width/2;
			_damagedBrick.y = -_damagedBrick.height/2;
			this.addChild(_damagedBrick);
		}
	}
}
