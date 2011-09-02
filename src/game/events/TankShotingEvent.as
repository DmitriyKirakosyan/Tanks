package game.events {
	import game.tank.Bullet;
	import flash.events.Event;

	public class TankShotingEvent extends Event {
		public var bullet:Bullet;
		
		public static const WAS_SHOT:String = "wasShot";
		
		public function TankShotingEvent(type : String, bullet:Bullet) {
			super(type);
			this.bullet = bullet;
		}
	}
}
