/**
 * User: dima
 * Date: 28/11/11
 * Time: 10:16 AM
 */
package game.mapObjects.bonus {
import flash.events.EventDispatcher;
import flash.events.TimerEvent;
import flash.utils.Timer;

import game.events.GameBonusEvent;
import game.mapObjects.MapObject;

public class BonusManager extends EventDispatcher {
	private var _activeBonusList:Vector.<GameBonus>;

	private var nextBonusType:uint;
	private var bonusTimer:Timer;

	public function BonusManager() {
		super();
	}

	/* API */

	public function removeBonus(gameBonus:GameBonus):void {
		removeActiveBonus(gameBonus);
	}

	public function dropBonus(bonusType:uint):void{
		nextBonusType = bonusType;
		if (!bonusTimer) {
			bonusTimer = new Timer(Math.round(Math.random()*1000) + 1000);
			bonusTimer.addEventListener(TimerEvent.TIMER, onBonusTimer);
		}
		if (bonusTimer.running) { bonusTimer.stop(); }
		bonusTimer.delay = Math.round(Math.random()*1000) + 1000;
		bonusTimer.reset();
		bonusTimer.start();
	}

	public function getBonusUnder(mapObject:MapObject):GameBonus {
		var result:GameBonus;
		for each (var gameBonus:GameBonus in _activeBonusList) {
			if (mapObject.hitTestObject(gameBonus)) {
				result = gameBonus;
				break;
			}
		}
		return result;
	}

	public function clear():void {
		while (_activeBonusList && _activeBonusList.length > 0) { removeActiveBonus(_activeBonusList[0]); }
		if (bonusTimer) { bonusTimer.stop(); }
	}

	public function get activeBonuseList():Vector.<GameBonus> { return _activeBonusList; }

	/* Internal functions */

	private function onBonusTimer(event:TimerEvent):void{
		bonusTimer.stop();
		addMedKit();
	}
	private function addMedKit():void{
		var gameBonus:GameBonus;
		switch (nextBonusType) {
			default : gameBonus = GameBonus.createMedkit();
		}
		addActiveBonus(gameBonus);
		dispatchEvent(new GameBonusEvent(GameBonusEvent.BONUS_ADDED, gameBonus));
	}

	private function removeActiveBonus(gameBonus:GameBonus):void{
		var index:int = _activeBonusList.indexOf(gameBonus);
		if (index != -1) {
			_activeBonusList.splice(index, 1);
		} else { trace("WARN!! bonus is not in list [BonusManager.removeActiveBonus]"); }
	}

	private function addActiveBonus(gameBonus:GameBonus):void {
		if (!_activeBonusList) { _activeBonusList = new Vector.<GameBonus>(); }
		if (_activeBonusList.indexOf(gameBonus) == -1) {
			_activeBonusList.push(gameBonus);
		}
	}

}
}
