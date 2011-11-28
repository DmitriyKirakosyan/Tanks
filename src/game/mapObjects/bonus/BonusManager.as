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

public class BonusManager extends EventDispatcher{
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

/*
	private function checkHitMedKit():void {
		if (!medKit) {return;}
		if (_playerTank.hitTestObject(medKit)){
			_playerTank.updateLive();
			removeMedKit();
			medKit = null;
		}
	}
	*/

	private function removeActiveBonus(gameBonus:GameBonus):void{
		var index:int = _activeBonusList.indexOf(gameBonus);
		if (index != -1) {
			_activeBonusList.splice(index, 1);
		}
	}

	private function addActiveBonus(gameBonus:GameBonus):void {
		if (!_activeBonusList) { _activeBonusList = new Vector.<GameBonus>(); }
		if (_activeBonusList.indexOf(gameBonus) != -1) {
			_activeBonusList.push(gameBonus);
		}
	}

}
}
