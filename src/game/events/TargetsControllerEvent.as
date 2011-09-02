package game.events {
	import game.tank.Tank;
	import flash.events.Event;

	public class TargetsControllerEvent extends Event {
		public var tank:Tank;
		
		public static const NEW_TANK:String = "newTank";
		
		public function TargetsControllerEvent(type : String, tank:Tank) {
			super(type);
			this.tank = tank;
		}
	}
}
