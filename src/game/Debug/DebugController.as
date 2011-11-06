package game.Debug {
	import flash.display.Sprite;
	import flash.events.EventDispatcher;



	public class DebugController extends EventDispatcher {
		
//		private var gameController:GameController;
//		private var targetController:TargetsController;
//		private var _container:Sprite;
//		private var mapMatrix:MapMatrix;
//		private var stopAddTank:Boolean = false;
//		private var tankDrag:Boolean = false;
		
		public function DebugController(container:Sprite):void {
		//	_container = container;
		//	gameController = new GameController(container);
		//	mapMatrix = new MapMatrix(_container);
		//	targetController = new TargetsController(container, mapMatrix);
		}
/*
		public function tankAddController(controller:TargetsController):void {
			if (!stopAddTank) {
				controller.timerAddTank.stop(); stopAddTank = true;
				trace("StopTankAdd"); }
			else if (stopAddTank) { controller.timerAddTank.start(); stopAddTank = false;
				trace("StartTankAdd"); }
		}

		public function tankMoveController(controller:TargetsController):void {
			if (!tankDrag) {
				tankDrag = true;
				_container.addEventListener(MouseEvent.MOUSE_DOWN, tankMoveON);
				_container.addEventListener(MouseEvent.MOUSE_UP, tankMoveOFF);
				trace("YES drag");
			}
			else if (tankDrag) {
				tankDrag = false;
				_container.removeEventListener(MouseEvent.MOUSE_DOWN, tankMoveON);
				_container.removeEventListener(MouseEvent.MOUSE_UP, tankMoveOFF);
				trace("NOT drag");
			}
		}
		
		private function tankMoveON(event:MouseEvent):void {
			targetController.tankStopMoving();
		}
		
		
		private function tankMoveOFF(event:MouseEvent):void {
			targetController.tankStartMoving();
		}
		*/

//		private function onDragTankButton(event:MouseEvent):void {
			
//			_debugController.tankMoveController(_targetsController);
			
			
			/*if (!tankDrag) {
				tankDrag = true;
				_container.addEventListener(MouseEvent.MOUSE_DOWN, tankPickUp);
				_container.addEventListener(MouseEvent.MOUSE_UP, tankPickDown);
				trace("YES drag");
			}
			else if (tankDrag) {
				tankDrag = false;
				_container.removeEventListener(MouseEvent.MOUSE_DOWN, tankPickUp);
				_container.removeEventListener(MouseEvent.MOUSE_UP, tankPickDown);
				trace("NOT drag");
			}*/
//		}
		
		/*private function tankPickUp(event:MouseEvent):void {
			_targetsController.tankStopMoving();
			
		}
		
		private function tankPickDown(event:MouseEvent):void {
			_targetsController.tankStartMoving();
			
		}*/
		
//		public function get timerAddTank():Timer { return _timer;}
		
		//TODO
/*		public function tankStopMoving():void {
			for each (var enemy:Tank in enemyes) {
				if (enemy.hitTestPoint(_container.mouseX, _container.mouseY)) {
					enemy.tankUseMouse = true;
					_playerTank = enemy;
					stopTank(enemy);
					_container.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
					enemy.filters = [new GlowFilter(0x00FF00,0.9)];
					break;
				}		
			}	
		}
		
		public function tankStartMoving():void{
			_playerTank.filters = null;
			_container.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			_playerTank.tankUseMouse = false;
			playTank(_playerTank);
			
		}
		
		private function onMouseMove(event:MouseEvent):void {
			_playerTank.originX = _container.mouseX;
			_playerTank.originY = _container.mouseY;
		}
		
		//TODO think about this
		private function stopTank(tank:Tank):void {
			for each (var tankController:TankController in _enemyes) {
				if (tank == tankController.tank) {
					tankController.movingTimeline.vars["onComplete"] = null;
					tankController.movingTimeline.killTweensOf(tank);
					tankController.autoAttackTimer.stop();
					break;
				}
			}
		}
		
		private function playTank(tank:Tank):void{
			for each (var tankController:TankController in _enemyes) {
				if (tank == tankController.tank) {
						moveEnemyTank(tankController);
						_container.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
						tankController.autoAttackTimer.start();
					break;
				}
			}
		}
		
//TODO доделать чтобы танк снова начал ехать, и аналогично проделать с остальными контроллерами (выстрел, столкновение)
*/		
		
	}
}
