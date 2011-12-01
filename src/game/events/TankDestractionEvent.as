/**
 * Created by : Dmitry
 * Date: 12/1/11
 * Time: 10:15 PM
 */
package game.events {
import flash.events.Event;

public class TankDestractionEvent extends Event{
	public static const TANK_DESTRAYED:String = "tankDestroyed";

	public function TankDestractionEvent(type:String) {
		super(type);
	}
}
}
