package game.mapObjects {
import flash.geom.Point;

import game.MapObject;
	import flash.geom.Rectangle;
	import flash.display.Sprite;

	public class Stone extends MapObject {
		private var _rect:Rectangle;
		private var _view:StoneView;
		
		public function Stone(point:Point) {
			super();
			_view = new StoneView();
			this.x = point.x;
			this.y = point.y;
			this.addChild(_view);
		}
		
		private function draw():void {
			this.graphics.beginFill(0x4ff11f, .6);
			this.graphics.drawRoundRect(0, 0, _rect.width, _rect.height, _rect.width, _rect.height);
			this.graphics.endFill();
		}
	}
}
