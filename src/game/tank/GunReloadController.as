package game.tank {
	import com.greensock.TweenLite;
	import com.bit101.components.ProgressBar;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	public class GunReloadController extends EventDispatcher{
		
		private var _reloadBar:ProgressBar;
		
		public function GunReloadController():void {
			super();
			createReloadBar();
		}
		
		/* API */
		
		public function reload():void {
			TweenLite.to(_reloadBar, 2, { value : 100, onComplete : onReloadComplete });
		}
		
		public function get reloadBar():Sprite {
			return _reloadBar;
		}
		
		/* Internal functions */
		
		private function onReloadComplete():void {
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
