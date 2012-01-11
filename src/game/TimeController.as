package game {
	import flash.display.Sprite;

import game.world.GameWorld;

public class TimeController {
		private var _container:Sprite;
		
		private var _controllers:Vector.<ControllerWithTime>;

		public static const NORMAL_TIME_SPEED:Number = 1;
		public static const SLOW_TIME_SPEED:Number = .14;
		
		public function TimeController(container:Sprite):void {
			super();
			_container = container;
		}
		
		/* API */

		public function add_controller(controllerWithTime:ControllerWithTime):void {
			if (!controllerWithTime) { return; }
			if (!_controllers) { _controllers = new Vector.<ControllerWithTime>(); }
			_controllers.push(controllerWithTime);
		}
		
		/* for debug */
		public function pauseWorld():void {
			/*
			for each (var controller:IControllerWithTime in _controllers) {
				controller.pause();
			}
			*/
		}
		public function resumeWorld():void {
			/*
			for each (var controller:IControllerWithTime in _controllers) {
				controller.resume();
			}
			*/
		}

		/** slow down time */
		public function slowDown():void {
			GameWorld.instance.timeScale = SLOW_TIME_SPEED;
			//scaleTime(.14);
		}
		
		/** normalize time */
		public function normalize():void {
			GameWorld.instance.timeScale = NORMAL_TIME_SPEED;
			//scaleTime(1);
		}
		
		/* Internal functions */
		
//		private function scaleTime(value:Number):void {
//			if (!_controllers) { return; }
//			for each (var controller:ControllerWithTime in _controllers) {
//				controller.scaleTime(value);
//			}
//		}
	}
}
