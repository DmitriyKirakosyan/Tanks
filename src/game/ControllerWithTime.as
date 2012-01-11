package game {
import flash.events.Event;
import flash.events.EventDispatcher;

import game.world.GameWorld;

public class ControllerWithTime extends EventDispatcher{

	public function ControllerWithTime():void {
		super();
		followWorld();
	}

	private function followWorld():void {
		GameWorld.instance.addEventListener(Event.CHANGE, onWorldChange);
	}

	private function onWorldChange(event:Event):void {
		scaleTime(GameWorld.instance.timeScale);
	}

	protected function scaleTime(timeScale:Number):void {}

}
}
