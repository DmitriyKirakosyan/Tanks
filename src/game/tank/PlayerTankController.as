/**
 * User: dima
 * Date: 30/11/11
 * Time: 5:03 PM
 */
package game.tank {
import flash.display.Sprite;
import flash.geom.Point;

import game.KeyboardListener;

import game.matrix.MapMatrix;

public class PlayerTankController extends TankController{
	private var _currentKeyDirection:uint;

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

	private function moveOnePoint(x:Number, y:Number, keyDirection:uint):void {
		trace("move one point " + Math.random() + "[PlayerTankController.moveOnePoint");
		readyForMoving();
		addPointToMovePath(_mapMatrix.correctMatrixPoint(x, y));
		_currentKeyDirection = keyDirection;
	}

	public function moveUp():void {
		if (tankPointIsCorrect() && canMoveToPoint(tank.x, tank.y - 1)) {
			moveOnePoint(tank.x,  tank.y-1, KeyboardListener.UP);
		} else if (triesMoveBack(KeyboardListener.UP)) {
			var correctedPoint:Point = tank.getCorrectedMapPosition();
			if (correctedPoint.y > tank.y) { correctedPoint.y--; }
			moveOnePoint(correctedPoint.x, correctedPoint.y, KeyboardListener.UP);
		}
	}
	public function moveDown():void {
		if (tankPointIsCorrect() && canMoveToPoint(tank.x, tank.y + 1)) {
			moveOnePoint(tank.x,  tank.y + 1, KeyboardListener.DOWN);
		} else if (triesMoveBack(KeyboardListener.DOWN)) {
			var correctedPoint:Point = tank.getCorrectedMapPosition();
			if (correctedPoint.y < tank.y) { correctedPoint.y++; }
			moveOnePoint(correctedPoint.x,  correctedPoint.y, KeyboardListener.DOWN);
		}
	}
	public function moveLeft():void {
		if (tankPointIsCorrect() && canMoveToPoint(tank.x - 1, tank.y)) {
			moveOnePoint(tank.x-1, tank.y, KeyboardListener.LEFT);
		} else if (triesMoveBack(KeyboardListener.LEFT)) {
			var correctedPoint:Point = tank.getCorrectedMapPosition();
			if (correctedPoint.x > tank.x) { correctedPoint.x--; }
			moveOnePoint(correctedPoint.x, correctedPoint.y, KeyboardListener.LEFT);
		}
	}
	public function moveRight():void {
		if (tankPointIsCorrect() && canMoveToPoint(tank.x + 1, tank.y)) {
			moveOnePoint(tank.x+1, tank.y, KeyboardListener.RIGHT);
		} else if (triesMoveBack(KeyboardListener.RIGHT)) {
			var correctedPoint:Point = tank.getCorrectedMapPosition();
			if (correctedPoint.x < tank.x) { correctedPoint.x++; }
			moveOnePoint(correctedPoint.x, correctedPoint.y, KeyboardListener.RIGHT);
		}
	}

	/* Internal functions */

	private function triesMoveBack(keyDirection:uint):Boolean {
		return  (keyDirection == KeyboardListener.LEFT && _currentKeyDirection == KeyboardListener.RIGHT) ||
						(keyDirection == KeyboardListener.RIGHT && _currentKeyDirection == KeyboardListener.LEFT) ||
						(keyDirection == KeyboardListener.UP && _currentKeyDirection == KeyboardListener.DOWN) ||
						(keyDirection == KeyboardListener.DOWN && _currentKeyDirection == KeyboardListener.UP)
	}

	private function tankPointIsCorrect():Boolean {
		var correctedPoint:Point = tank.getCorrectedMapPosition();
		return Math.abs(tank.x - correctedPoint.x) < .2 && Math.abs(tank.y - correctedPoint.y) < .2;
	}

	private function canMoveToPoint(x:Number, y:Number):Boolean {
		var correctedPoint:Point = _mapMatrix.correctMatrixPoint(x, y);
		return _mapMatrix.isFreeCell(correctedPoint.x, correctedPoint.y) && _mapMatrix.isFreeTankCell(correctedPoint.x, correctedPoint.y);
	}

}
}
