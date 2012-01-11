/**
 * User: dima
 * Date: 11/01/12
 * Time: 12:28 PM
 */
package game.world {
import flash.events.Event;
import flash.events.EventDispatcher;

public class GameWorld extends EventDispatcher{
	private var _timeScale:Number;

	private static var _instance:GameWorld;

	public static function get instance():GameWorld {
		if (!_instance) { _instance = new GameWorld(); }
		return _instance;
	}

	public function GameWorld() {
		super();
		_timeScale = 1;
	}

	public function get timeScale():Number { return _timeScale; }
	public function set timeScale(value:Number):void {
		_timeScale = value;
		dispatchEvent(new Event(Event.CHANGE));
	}
}
}
