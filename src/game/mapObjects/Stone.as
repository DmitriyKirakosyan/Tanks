package game.mapObjects {
import flash.geom.Point;

import game.mapObjects.MapObject;

	public class Stone extends MapObject {
		private var _view:StoneView;
		
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
		
	}
}
