package game.events {
	import flash.events.Event;

	public class GunRotateCompleteEvent extends Event {

		public static const COMPLETE:String = "rotateComplete";
		public function GunRotateCompleteEvent(type : String) {
			super(type);
		}
	}
}
