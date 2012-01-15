/**
 * User: dima
 * Date: 1/15/12
 * Time: 2:01 PM
 */
package game.mapObjects {
import flash.display.Sprite;
import flash.geom.Point;

public class MapNativeObject extends MapObject {
	private var _view:Sprite;

	public function MapNativeObject(point:Point, objectView:Sprite) {
		super();
		this.x = point.x;
		this.y = point.y;
		_view = objectView;
		objectView.x -= objectView.width/2;
		objectView.y -= objectView.height/2;
		this.addChild(objectView);
	}
}
}
