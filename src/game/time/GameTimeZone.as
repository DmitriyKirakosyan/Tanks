/**
 * User: dima
 * Date: 28/11/11
 * Time: 5:02 PM
 */
package game.time {
import flash.geom.Point;

import game.mapObjects.MapObject;

public class GameTimeZone {
	private var _point:Point;
	private var _radius:Number;
	private var _straight:Number;


	public function GameTimeZone(point:Point, radius:Number, straight:Number = 1) {
		super();
		_point = point;
		_radius = radius;
		_straight = straight;
	}

	/* API */

	public function get straight():Number { return _straight; }

	public function objectInZone(object:MapObject):Boolean {
		var objectPoint:Point = new Point(object.originX, object.originY);
		if (Point.distance(_point, objectPoint) < _radius) { return true; }
		return false;
	}


}
}
