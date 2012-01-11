package game.tank.weapon {
import com.greensock.TweenMax;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.EventDispatcher;

import game.ControllerWithTime;

public class GunReloadController extends EventDispatcher implements ControllerWithTime{
	private var _reloadBar:ReloadBar;
	private var _reloading:Boolean;
	private var _reloadTween:TweenMax;

	private var _speed:Number;

	private var _scaleTime:Number = 1;

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
		_scaleTime = value;
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
		_reloadTween = new TweenMax(_reloadBar, 1/_speed, { scaleX : 1, onComplete : onReloadComplete });
		if (_scaleTime != 1) { _reloadTween.timeScale = _scaleTime; trace("scale time [GunReloadController.reload]"); }
	}

	public function get reloadBar():Sprite {
		return _reloadBar;
	}

	/* Internal functions */

	private function onReloadComplete():void {
		_reloading = false;
		_reloadBar.scaleX = 0;
		dispatchEvent(new Event(Event.COMPLETE));
	}

	private function createReloadBar():void {
		_reloadBar = new ReloadBar();
		_reloadBar.scaleX = 0;
	}
}
}
