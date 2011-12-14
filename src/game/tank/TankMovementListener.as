package game.tank {
import flash.geom.Point;

import game.drawing.MouseDrawController;
	import game.mapObjects.MapObjectsController;
	import game.events.TankEvent;
	import game.tank.TankController;
	public class TankMovementListener {
		private var _tankController:TankController;
		private var _mapObjectsController:MapObjectsController;
		private var _mouseDrawController:MouseDrawController;
		
		public function TankMovementListener(tankController:TankController,
																					mapObjectsController:MapObjectsController,
																					mouseDrawController:MouseDrawController):void {
			super();
			_tankController =  tankController;
			_mapObjectsController = mapObjectsController;
			_mouseDrawController = mouseDrawController;
			addListeners();
		}
		
		/* Internal functions */
		private function addListeners():void {
			_tankController.addEventListener(TankEvent.COME_TO_CELL, onTankComeToCell);
			_tankController.addEventListener(TankEvent.MOVING_COMPLETE, onTankMovingComplete);
		}
		
		private function onTankComeToCell(event:TankEvent):void {
			var lastPathPoint:Point = _mouseDrawController.getFirstMovePoint();
			if (!lastPathPoint) { return; }
			if (Math.abs(lastPathPoint.x - _tankController.tank.x) > .5 ||
							Math.abs(lastPathPoint.y - _tankController.tank.y) > .5) {
				_mouseDrawController.removePart();
			}
		}

		private function onTankMovingComplete(event:TankEvent):void {
			_mouseDrawController.removePart();
		}
		
	}
}
