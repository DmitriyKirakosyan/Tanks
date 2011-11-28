/**
 * User: dima
 * Date: 28/11/11
 * Time: 10:30 AM
 */

package game.mapObjects.bonus {
import com.greensock.TweenMax;
import com.greensock.easing.Back;

import flash.events.Event;

import game.mapObjects.MapObject;

public class GameBonus extends MapObject {
	private var _type:uint;

	public static const MEDKIT:uint = 0;

	public static function createMedkit():GameBonus {
		return new MedKit();
	}

	public function GameBonus(type:uint) {
		super();
		_type = type;
		this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
	}

	public function get type():uint { return _type; }

	private function onAddedToStage(event:Event):void {
		this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		this.scaleX = this.scaleY = .1;
		new TweenMax(this, .5, {scaleX : .7, scaleY : .7, ease : Back.easeOut });
	}
}
}