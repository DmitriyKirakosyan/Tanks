package game.events {
	import game.tank.Bullet;
	import flash.events.Event;

	public class TankShotingEvent extends Event {
		public var bullet:Bullet;
		
		public static const WAS_SHOT:String = "wasShot";
		public static const CANT_SHOT:String = "cantShot";
		
		public function TankShotingEvent(type : String, bullet:Bullet) {
			super(type);
			this.bullet = bullet;
			//TODO трейс на эту ф-цию срабатывает при выстреле вражеского танка 2 раза
		}
	}
}
