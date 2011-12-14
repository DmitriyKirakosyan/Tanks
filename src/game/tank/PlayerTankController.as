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
		highlightPlayerTank();
	}

	private function highlightPlayerTank():void {
		var colorTank:ColorTransform = new ColorTransform();
		colorTank.color = 0x0000ff;
		tank.tankBase.transform.colorTransform = colorTank;
	}

}
}
