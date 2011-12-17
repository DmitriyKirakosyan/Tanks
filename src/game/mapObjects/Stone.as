package game.mapObjects {
import flash.geom.Point;

import game.mapObjects.MapObject;

	public class Stone extends MapObject {
		private var _view:StoneView;
		
		private var _damagedStone:DamagedBriksView;

		public function Stone(point:Point) {
			super();
			setHp(ObjectsHp.STONE);
			_view = new StoneView();
			_view.x -= _view.width/2;
			_view.y -= _view.height/2;
			this.x = point.x;
			this.y = point.y;
			this.addChild(_view);
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
