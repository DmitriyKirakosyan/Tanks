package game.events {
	import game.MapObject;
	import flash.events.Event;

	public class DamageObjectEvent extends Event {
		public var object:MapObject;
		
		public static const DAMAGE_ENEMY_TANK:String = "damageEnemyTank";
		public static const DAMAGE_PLAYER_TANK:String = "damagePlayerTank";
		
		public function DamageObjectEvent(type : String, mapObject:MapObject) {
			super(type);
			object = mapObject;
		}
	}
}
