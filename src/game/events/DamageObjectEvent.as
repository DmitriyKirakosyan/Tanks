package game.events {
	import game.mapObjects.MapObject;
	import flash.events.Event;

	public class DamageObjectEvent extends Event {
		public var object:MapObject;
		public var damageValue:Number;
		
		public static const DAMAGE_ENEMY_TANK:String = "damageEnemyTank";
		public static const DAMAGE_PLAYER_TANK:String = "damagePlayerTank";
		
		public function DamageObjectEvent(type : String, mapObject:MapObject, damageValue:Number) {
			super(type);
			object = mapObject;
			this.damageValue = damageValue;
		}
	}
}
