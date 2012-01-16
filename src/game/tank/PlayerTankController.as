/**
 * User: dima
 * Date: 30/11/11
 * Time: 5:03 PM
 */
package game.tank {
import com.greensock.TweenLite;
import com.greensock.easing.Linear;

import flash.display.Sprite;
import flash.geom.Point;

import game.KeyboardListener;

import game.KeyboardListener;
import game.matrix.MapMatrix;

public class PlayerTankController extends TankController{
	private var _currentKeyDirection:uint;

	private var _speedIncrement:Number;
	private var _targetMovePoint:Point;
	private var _moving:Boolean;

	private var _trackList:Vector.<Track>;

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
		_speedIncrement = 1/25 * (tank.vo.speed/5);
		_moving = false;
	}

	override public function remove():void {
		super.remove();
		for each (var track:Track in _trackList) {
			if (container.contains(track)) { container.removeChild(track); }
		}
		_trackList = null;
	}

	override public function tick():void {
		if (_moving) {
			if (_currentKeyDirection == KeyboardListener.LEFT) { tank.x -= _speedIncrement;
			} else if (_currentKeyDirection == KeyboardListener.RIGHT) { tank.x += _speedIncrement;
			} else {
				_currentKeyDirection == KeyboardListener.UP ? tank.y -= _speedIncrement : tank.y += _speedIncrement;
			}

			var track:Track = new Track();
			if (_currentKeyDirection == KeyboardListener.LEFT || _currentKeyDirection == KeyboardListener.RIGHT) {
				track.rotation = 90;
				track.y = tank.originY;
				track.x = (_currentKeyDirection == KeyboardListener.LEFT) ? tank.originX + tank.tankBase.width/2 : tank.originX - tank.tankBase.width/2;
			} else {
				track.x = tank.originX;
				track.y = (_currentKeyDirection == KeyboardListener.UP) ? (tank.originY + tank.tankBase.height/2) :
										tank.originY - tank.tankBase.height/2;
			}
			container.addChild(track);
			TweenLite.to(track, 2, { alpha : 0, ease:Linear.easeNone,
					onComplete:function():void { removeTrack(track); } });
			addTrack(track);

			if (needStop()) {
				tank.x = _targetMovePoint.x;
				tank.y = _targetMovePoint.y;
				_moving = false;
				onMovingComplete();
			}
		}
	}

	private function needStop():Boolean {
		return  _currentKeyDirection == KeyboardListener.DOWN && _targetMovePoint.y < tank.y ||
						_currentKeyDirection == KeyboardListener.UP && _targetMovePoint.y > tank.y ||
						_currentKeyDirection == KeyboardListener.LEFT && _targetMovePoint.x > tank.x ||
						_currentKeyDirection == KeyboardListener.RIGHT && _targetMovePoint.x < tank.x;
	}

	private function addTrack(track:Track):void {
		if (!track) { return; }
		if (!_trackList) { _trackList = new Vector.<Track>(); }
		_trackList.push(track);
	}

	private function removeTrack(track:Track):void {
		if (container.contains(track)) { container.removeChild(track); }
		if (!_trackList) { return; }
		var index:int = _trackList.indexOf(track);
		if (index != -1) {
			_trackList.splice(index, 1);
		}
	}

	override protected function createTank(tankVO:TankVO):void {
		tank = Tank.createPlayerTank(tankVO);
	}

	private function moveOnePoint(x:Number, y:Number, keyDirection:uint):void {
		trace("move one point " + Math.random() + "[PlayerTankController.moveOnePoint");
		readyForMoving();
		var point:Point = _mapMatrix.correctMatrixPoint(x, y);
		if (!_targetMovePoint || (point && (point.x != _targetMovePoint.x || point.y != _targetMovePoint.y))) {
			addPointToMovePath(point);
			_currentKeyDirection = keyDirection;
		}
	}

	override public function addPointToMovePath(point:Point):void {
		_targetMovePoint = point;
		_moving = true;
		onStartMoveToPathNode(point);
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
