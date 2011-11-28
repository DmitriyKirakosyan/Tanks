/**
 * User: dima
 * Date: 28/11/11
 * Time: 11:08 AM
 */
package game.events {
import flash.events.Event;

import game.mapObjects.bonus.GameBonus;

public class GameBonusEvent extends Event{
	private var _bonus:GameBonus;

	public static const BONUS_ADDED:String = "bonusAdded";

	public function GameBonusEvent(type:String, gameBonus:GameBonus) {
		super(type);
		_bonus = gameBonus;
	}

	public function get bonus():GameBonus { return _bonus; }
}
}
