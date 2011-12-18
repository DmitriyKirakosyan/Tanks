/**
 * Created by IntelliJ IDEA.
 * User: dima
 * Date: 1/11/11
 * Time: 5:11 PM
 * To change this template use File | Settings | File Templates.
 */
package game.tank.destruction {
import flash.events.Event;
import flash.display.MovieClip;
import game.events.TankDestructionEvent;

import com.greensock.TimelineMax;
import com.greensock.TweenMax;

import game.tank.Tank;

public class TankDestroyRotation extends TankDestroyMethod{

    private var _bamTimeline:TimelineMax;
	private var _effectSprite:MovieClip;

    public function TankDestroyRotation(tank:Tank) {
        super(tank);
    }

    override public function destroy():void {
		 _bamTimeline = new TimelineMax({onComplete : onBamComplete});
		
		_effectSprite = new Blow();
		
		 _bamTimeline.append(
            new TweenMax(tank, 1.5, {alpha : 0})
        );
		_bamTimeline.append(
            new TweenMax(_effectSprite, 1.5, {alpha : 0})
        );
		_effectSprite.scaleX = _effectSprite.scaleY = 1.3;
		_effectSprite.addEventListener(Event.ENTER_FRAME, onEffectEnterFrame);
		tank.addChild(_effectSprite);
		
        _bamTimeline.insert(
            new TweenMax(tank.tankBase, 1.3, {x : tank.tankBase.x + Math.random()*80-40,
                                                                y : tank.tankBase.y + Math.random()*80-40,
                                                                rotation : tank.tankBase.rotation + Math.random()*100})
        );
        _bamTimeline.insert(
            new TweenMax(tank.gun, 1.2, {x : tank.gun.x + Math.random()*400-300,
                                                            y : tank.tankBase.y + Math.random()*400-300,
                                                            rotation : tank.tankBase.rotation + Math.random()*300})
        );
       
    }
	private function onEffectEnterFrame(event:Event):void {
		if (_effectSprite.currentFrame >= _effectSprite.totalFrames) {
			_effectSprite.removeEventListener(Event.ENTER_FRAME, onEffectEnterFrame);
			tank.removeChild(_effectSprite);
		}
	}
    private function onBamComplete():void {
        dispatchEvent(new TankDestructionEvent(TankDestructionEvent.TANK_DESTRAYED));
    }

}
}
