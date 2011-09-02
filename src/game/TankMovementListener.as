package game {
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
		}
		
		private function onTankComeToCell(event:TankEvent):void {
			_mapObjectsController.checkReactionForTank(_tankController.tank);
			_mouseDrawController.removePart();
		}
		
	}
}
