package game.mapObjects {
	import flash.geom.Point;

	import game.mapObjects.MapObject;

	public class Brick extends MapObject {

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
			this.scaleX = .5 + hp/maxHp/2;
			this.scaleY = .5 + hp/maxHp/2;
			if (hp < maxHp/2) {
				breakBrick();
			}
		}
		
		public function get damaged():Boolean { return hp < maxHp/2; }

		/* Internal functions */

		private function breakBrick():void {
			const damagedBrick:DamagedBriksView = new DamagedBriksView();
			damagedBrick.x = -damagedBrick.width/2;
			damagedBrick.y = -damagedBrick.height/2;
			this.addChild(damagedBrick);
		}
	}
}
