package game {
	import flash.display.Sprite;

	public class TimeController {
		private var _container:Sprite;
		
		private var _controllers:Vector.<IControllerWithTime>;
		
		public function TimeController(container:Sprite):void {
			super();
			_container = container;
		}
		
		/* API */
		
		public function add_controller(controllerWithTime:IControllerWithTime):void {
			if (!controllerWithTime) { return; }
			if (!_controllers) { _controllers = new Vector.<IControllerWithTime>(); }
			_controllers.push(controllerWithTime);
		}
		
		/** slow down time */
		public function slowDown():void {
			scaleTime(.14);
		}
		
		/** normalize time */
		public function normalize():void {
			scaleTime(1);
		}
		
		/* Internal functions */
		
		private function scaleTime(value:Number):void {
			if (!_controllers) { return; }
			for each (var controller:IControllerWithTime in _controllers) {
				controller.scaleTime(value);
			}
		}
	}
}
