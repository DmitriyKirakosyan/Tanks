package game.tank.weapon {
import com.bit101.components.ProgressBar;
import com.greensock.TweenMax;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.EventDispatcher;

import game.IControllerWithTime;

public class GunReloadController extends EventDispatcher implements IControllerWithTime{
	private var _reloadBar:ProgressBar;
	private var _reloading:Boolean;
	private var _reloadTween:TweenMax;

	private var _speed:Number;

	public function GunReloadController(reloadSpeed:Number):void {
		super();
		_reloading = false;
		_speed = reloadSpeed;
		createReloadBar();
	}

	/* API */

	public function get reloading():Boolean { return _reloading; }

	/* time functions */

	public function scaleTime(value:Number):void {
		if (_reloadTween) { _reloadTween.timeScale = value; }
	}

	public function pause():void {
		if (_reloadTween) { _reloadTween.pause(); }
	}
	public function resume():void {
		if (_reloadTween) { _reloadTween.resume(); }
	}

	public function reload():void {
		_reloading = true;
		if (_reloadTween) {
			_reloadTween.vars["onComplete"] = null;
			TweenMax.killTweensOf(_reloadBar);
		}
		_reloadTween = new TweenMax(_reloadBar, 1/_speed, { value : 100, onComplete : onReloadComplete });
	}

	public function get reloadBar():Sprite {
		return _reloadBar;
	}

	/* Internal functions */

	private function onReloadComplete():void {
		_reloading = false;
		_reloadBar.value = 0;
		dispatchEvent(new Event(Event.COMPLETE));
	}

	private function createReloadBar():void {
		_reloadBar = new ProgressBar();
		_reloadBar.maximum = 100;
		_reloadBar.value = 0;
		_reloadBar.width = 40;
	}

}
}
