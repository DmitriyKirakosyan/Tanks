/**
 * Created by : Dmitry
 * Date: 11/1/11
 * Time: 11:51 PM
 */
package game.tank.destruction {
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;

import game.events.TankDestructionEvent;

import com.greensock.TweenMax;

import game.tank.Tank;

public class TankDestroyFlash extends TankDestroyMethod{
	private var _effectSprite:MovieClip;

	public function TankDestroyFlash(tank:Tank):void {
		super(tank);
	}

	override public function destroy():void {
		if (_effectSprite) {
			return;
		}
		tank.hide();
		_effectSprite = new NewGameBtn();
		_effectSprite.addEventListener(Event.ENTER_FRAME, onEffectEnterFrame);
		tank.addChild(_effectSprite);
	}

	private function onEffectEnterFrame(event:Event):void {
		if (_effectSprite.currentFrame >= _effectSprite.totalFrames) {
			_effectSprite.removeEventListener(Event.ENTER_FRAME, onEffectEnterFrame);
			tank.removeChild(_effectSprite);
			onDestoryComplete();
		}
	}

	private function onDestoryComplete():void {
		dispatchEvent(new TankDestructionEvent(TankDestructionEvent.TANK_DESTRAYED));
	}
}
}
