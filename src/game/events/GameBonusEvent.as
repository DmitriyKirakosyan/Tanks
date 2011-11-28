/**
 * User: dima
 * Date: 28/11/11
 * Time: 11:08 AM
 */
package game.events {
import flash.events.Event;

import game.mapObjects.bonus.GameBonus;
import game.tank.Tank;

public class GameBonusEvent extends Event{
	private var _bonus:GameBonus;
	private var _tank:Tank;

	public static const BONUS_ADDED:String = "bonusAdded";
	public static const BONUS_APPLY_TO_PLAYER:String = "bonusApplyToPlayer";

	public static function createBonusAddedEvent(bonus:GameBonus):GameBonusEvent {
		return new GameBonusEvent(BONUS_ADDED, bonus);
	}
	public static function createBonusApplyToPlayerEvent(bonus:GameBonus):GameBonusEvent {
		return new GameBonusEvent(BONUS_APPLY_TO_PLAYER, bonus);
	}

	public function GameBonusEvent(type:String, gameBonus:GameBonus, tank:Tank = null) {
		super(type);
		_bonus = gameBonus;
		if (tank) { _tank = tank; }
	}

	public function get bonus():GameBonus { return _bonus; }
	public function get tank():Tank { return _tank; }
}
}
