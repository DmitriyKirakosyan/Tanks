package game.mapObjects {
import flash.geom.Point;

import game.mapObjects.MapObject;

	public class Stone extends MapNativeObject {

		private var _damagedStone:DamagedBriksView;

		public function Stone(point:Point) {
			super(point, new StoneView());
			setHp(ObjectsHp.STONE);
		}

		override public function damage(value:Number):void {
			super.damage(value);
			if (!_damagedStone) {
				breakStone();
			}
			_damagedStone.alpha = 1-hp/maxHp;
		}
		
		/* Internal functions */

		private function breakStone():void {
			_damagedStone = new DamagedBriksView();
			_damagedStone.x = -_damagedStone.width/2;
			_damagedStone.y = -_damagedStone.height/2;
			this.addChild(_damagedStone);
		}
	}
}
