package game.events {
	import game.tank.TankController;
	import flash.events.Event;

	public class TankEvent extends Event {
		public var tankController:TankController;
		
		public static const COME_TO_CELL:String = "comeToCell";
		public static const MOVING_COMPLETE:String = "movingComplete";
		
		public function TankEvent(type : String, tankController:TankController = null) {
			super(type);
			this.tankController = tankController;
		}
	}
}
