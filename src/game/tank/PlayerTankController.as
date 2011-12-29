/**
 * User: dima
 * Date: 30/11/11
 * Time: 5:03 PM
 */
package game.tank {
import flash.display.Sprite;
import flash.geom.ColorTransform;
import flash.geom.Point;

import game.matrix.MapMatrix;

public class PlayerTankController extends TankController{
	public function PlayerTankController(container:Sprite, mapMatrix:MapMatrix) {
		super(container,  mapMatrix);
	}

	override public function init(tankVO:TankVO):void {
		super.init(tankVO);
		var matrixPoint:Point = _mapMatrix.getMatrixPoint(new Point(300, 300));
		tank.x = matrixPoint.x;
		tank.y = matrixPoint.y;
		_mapMatrix.setTankCell(tank.x,  tank.y,  1);
		tank.addReloadBar(gunController.reloadController.reloadBar);
	}

	override protected function createTank(tankVO:TankVO):void {
		tank = Tank.createPlayerTank(tankVO);
	}

	public function moveUp():void {
		if (tankPointIsCorrect() && canMoveToPoint(tank.x, tank.y - 1)) {
			readyForMoving();
			addPointToMovePath(new Point(tank.x, tank.y - 1));
		}
	}
	public function moveDown():void {
		if (tankPointIsCorrect() && canMoveToPoint(tank.x, tank.y + 1)) {
			readyForMoving();
			addPointToMovePath(new Point(tank.x, tank.y + 1));
		}
	}
	public function moveLeft():void {
		if (tankPointIsCorrect() && canMoveToPoint(tank.x - 1, tank.y)) {
			readyForMoving();
			addPointToMovePath(new Point(tank.x - 1, tank.y));
		}
	}
	public function moveRight():void {
		if (tankPointIsCorrect() && canMoveToPoint(tank.x + 1, tank.y)) {
			readyForMoving();
			addPointToMovePath(new Point(tank.x + 1, tank.y));
		}
	}

	/* Internal functions */

	private function tankPointIsCorrect():Boolean {
		var correctedPoint:Point = tank.getCorrectedMapPosition();
		return tank.x == correctedPoint.x && tank.y == correctedPoint.y;
	}

	private function canMoveToPoint(x:Number, y:Number):Boolean {
		return _mapMatrix.isFreeCell(x, y) && _mapMatrix.isFreeTankCell(x, y);
	}

}
}
