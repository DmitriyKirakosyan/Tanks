package game.events {
	import flash.geom.Point;
	import flash.events.Event;

	public class MineBamEvent extends Event {
		public var minePoint:Point;
		public var distantion:int;
		
		public static const BAM:String = "bam";
		
		public function MineBamEvent(type : String, distantion:int, point:Point) {
			super(type);
			minePoint = point;
			this.distantion = distantion;
		}
	}
}
