/**
 * Created by : Dmitry
 * Date: 11/1/11
 * Time: 11:35 PM
 */
package game.tank.tank_destraction {
import flash.events.Event;

public class TankDestoryEvent extends Event{

	public static const DESTORY_COMPLETE:String = "destoryComplete";
	public function TankDestoryEvent(type:String):void {
		super(type);
	}
}
}