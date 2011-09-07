package game.events {
import flash.events.Event;

public class SceneEvent extends Event{
	public var reason:String;

	public static const WANT_REMOVE:String = "wantRemove";
	public function SceneEvent(type:String) {
		super(type);
	}
}
}
