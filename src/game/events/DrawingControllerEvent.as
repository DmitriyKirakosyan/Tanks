package game.events {
	import flash.events.Event;

	public class DrawingControllerEvent extends Event {
		
		public static const DRAWING_COMPLETE:String = "drawingComplete";
		public static const PATH_CLOSED:String = "pathClosed";
		public static const NEW_MOVE_POINT:String = "newMovePoint";
		public static const WANT_START_DRAW:String = "wantStartDraw";
		
		public function DrawingControllerEvent(eventType:String) {
			super(eventType);
		}
	}
}
