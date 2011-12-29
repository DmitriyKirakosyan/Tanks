/**
 * User: dima
 * Date: 30/11/11
 * Time: 5:03 PM
 */
package game.tank {
import flash.display.Sprite;
import flash.geom.ColorTransform;
import flash.geom.Point;

import game.KeyboardListener;

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
		} else if (tryMoveBack(KeyboardListener.UP)) {
			readyForMoving();
			var correctedPoint:Point = tank.getCorrectedMapPosition();
			if (correctedPoint.y > tank.y) { correctedPoint.y--; }
			addPointToMovePath(new Point(correctedPoint.x, correctedPoint.y));
		}
	}
	public function moveDown():void {
		if (tankPointIsCorrect() && canMoveToPoint(tank.x, tank.y + 1)) {
			readyForMoving();
			addPointToMovePath(new Point(tank.x, tank.y + 1));
		} else if (tryMoveBack(KeyboardListener.DOWN)) {
			readyForMoving();
			var correctedPoint:Point = tank.getCorrectedMapPosition();
			if (correctedPoint.y < tank.y) { correctedPoint.y++; }
			addPointToMovePath(new Point(correctedPoint.x, correctedPoint.y));
		}
	}
	public function moveLeft():void {
		if (tankPointIsCorrect() && canMoveToPoint(tank.x - 1, tank.y)) {
			readyForMoving();
			addPointToMovePath(new Point(tank.x - 1, tank.y));
		} else if (tryMoveBack(KeyboardListener.LEFT)) {
			readyForMoving();
			var correctedPoint:Point = tank.getCorrectedMapPosition();
			if (correctedPoint.x > tank.x) { correctedPoint.x--; }
			addPointToMovePath(new Point(correctedPoint.x, correctedPoint.y));
		}
	}
	public function moveRight():void {
		if (tankPointIsCorrect() && canMoveToPoint(tank.x + 1, tank.y)) {
			readyForMoving();
			addPointToMovePath(new Point(tank.x + 1, tank.y));
		} else if (tryMoveBack(KeyboardListener.RIGHT)) {
			readyForMoving();
			var correctedPoint:Point = tank.getCorrectedMapPosition();
			if (correctedPoint.x < tank.x) { correctedPoint.x++; }
			addPointToMovePath(new Point(correctedPoint.x, correctedPoint.y));
		}
	}

	/* Internal functions */

	private function tryMoveBack(keyDirection:uint):Boolean {
		var correctedPoint:Point = tank.getCorrectedMapPosition();
		var result:Boolean = false;
		switch(keyDirection) {
			case KeyboardListener.LEFT:
				result = (tank.x > correctedPoint.x) && canMoveToPoint(correctedPoint.x,  correctedPoint.y);
				break;
			case KeyboardListener.RIGHT:
				result = (tank.x < correctedPoint.x) && canMoveToPoint(correctedPoint.x,  correctedPoint.y);
				break;
			case KeyboardListener.UP:
				result = (tank.y > correctedPoint.y) && canMoveToPoint(correctedPoint.x,  correctedPoint.y);
				break;
			default:
				result = (tank.y < correctedPoint.y) && canMoveToPoint(correctedPoint.x,  correctedPoint.y);
				break;
		}
		return result;
	}

	private function tankPointIsCorrect():Boolean {
		var correctedPoint:Point = tank.getCorrectedMapPosition();
		return tank.x == correctedPoint.x && tank.y == correctedPoint.y;
	}

	private function canMoveToPoint(x:Number, y:Number):Boolean {
		return _mapMatrix.isFreeCell(x, y) && _mapMatrix.isFreeTankCell(x, y);
	}

}
}
