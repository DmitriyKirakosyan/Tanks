package game.matrix {
import flash.geom.Rectangle;
import flash.geom.Point;
import game.GameController;
import flash.display.Sprite;

import game.matrix.MatrixItemIds;

public class MapMatrix {
	private var _matrix:Vector.<Vector.<uint>>;
	private var _tankMatrix:Vector.<Vector.<uint>>;

	/* for debug (drawing web) */
	private var _container:Sprite;

	public static const MATRIX_WIDTH:int = 15;
	public static const MATRIX_HEIGHT:int = 15;

	public function MapMatrix(container:Sprite) {
		_container = container;
		_matrix = createEmptyMatrix();
		_tankMatrix = createEmptyMatrix();
	}

	public function get matrix():Vector.<Vector.<uint>> {
		return _matrix;
	}
	public function get tankMatrix():Vector.<Vector.<uint>> {
		return _tankMatrix;
	}

	public function getMatrixPoint(point:Point):Point{
		return new Point(int(point.x / GameController.CELL), int(point.y / GameController.CELL));
	}

	public function correctMatrixPoint(x:Number, y:Number):Point {
		var correctedX:int = x < 0 ? x - .5 : x + .5;
		var correctedY:int = y < 0 ? y - .5 : y + .5;
		return new Point(correctedX,correctedY);
	}

	public function getStagePoint(point:Point):Point {
		return new Point(point.x * GameController.CELL + GameController.CELL/2,
											point.y * GameController.CELL + GameController.CELL/2);
	}

	public function getRandomPoint():Point {
		return new Point(int(Math.random() * MATRIX_WIDTH),
											int(Math.random() * MATRIX_HEIGHT));
	}

	public function getStageRectangle(point:Point):Rectangle {
		return new Rectangle (point.x * GameController.CELL, point.y * GameController.CELL,
													GameController.CELL, GameController.CELL);
	}

	public function getNeighborElementPoint(item:int):Point {
		return new Point(MATRIX_WIDTH/2, MATRIX_HEIGHT/2);
	}

	public function getSpeedForTank(point:Point):Number {
		if (_matrix[point.x][point.y] == 0) { return 1;
		} else { return 1.6; }
	}

	public function drawMatrix():void {
		_container.graphics.lineStyle(1, 0x00BBFF, .1);
		for (var i:int = 0; i <= MATRIX_WIDTH; ++i) {
			_container.graphics.moveTo(i * GameController.CELL, 0);
			_container.graphics.lineTo(i * GameController.CELL, MATRIX_HEIGHT * GameController.CELL);
		}
		for (var j:int = 0; j <= MATRIX_HEIGHT; ++j) {
			_container.graphics.moveTo(0, j * GameController.CELL);
			_container.graphics.lineTo(MATRIX_WIDTH * GameController.CELL, j * GameController.CELL);
		}
	}

	public function clearCell(x:int, y:int):void {
		if (!pointInMatrix(x, y)) { return; }
		_matrix[x][y] = MatrixItemIds.EMPTY;
	}
	public function setCell(x:int, y:int, cellId:int):void {
		if (!pointInMatrix(x,  y)) { return; }
		_matrix[x][y] = cellId;
	}
	public function isFreeCell(x:int,  y:int):Boolean {
		if (!pointInMatrix(x,  y)) { return false; }
		return _matrix[x][y] == MatrixItemIds.EMPTY;
	}

	public function clearTankCell(x:int,  y:int):void {
		if (!pointInMatrix(x,  y)) { return; }
		_tankMatrix[x][y] = MatrixItemIds.EMPTY;
	}
	public function setTankCell(x:int, y:int, cellId:int):void {
		if (!pointInMatrix(x,  y)) { return; }
		_tankMatrix[x][y] = cellId;
	}
	public function isFreeTankCell(x:int, y:int):Boolean {
		if (!pointInMatrix(x,  y)) { return false; }
		return _tankMatrix[x][y] == MatrixItemIds.EMPTY;
	}

	public function remove():void {
	}

	public function createEmptyMatrix():Vector.<Vector.<uint>> {
		const matrix:Vector.<Vector.<uint>> = new Vector.<Vector.<uint>>();
		for (var i:int = 0; i < MATRIX_WIDTH; ++i) {
			matrix.push(new Vector.<uint>());
			for (var j:int = 0; j < MATRIX_HEIGHT; ++j) {
				matrix[i].push(MatrixItemIds.EMPTY);
			}
		}
		return matrix;
	}

	public function createMatrix():void {
		var rnd:Number;
		for (var i:int = 0; i < _matrix.length; ++i) {
			for (var j:int = 0; j < MATRIX_HEIGHT; ++j) {
				if (i == int(MATRIX_WIDTH/2) && j == int(MATRIX_HEIGHT/2)) {
					_matrix[i][j] = MatrixItemIds.EMPTY;
				} else {
					rnd = Math.random();
					_matrix[i][j] = rnd > .2 ?  MatrixItemIds.EMPTY :
																rnd < .1 ? MatrixItemIds.STONE : MatrixItemIds.BRICKS;
				}
			}
		}
	}
	public function createLoadMatrix(loadMatrix:Array):void {
		var rnd:Number = 0;
		for (var i:int = 0; i < _matrix.length; ++i) {
			for (var j:int = 0; j < MATRIX_HEIGHT; ++j) {
				if (i == int(MATRIX_WIDTH / 2) && j == int(MATRIX_HEIGHT / 2)) {
					_matrix[i][j] = MatrixItemIds.EMPTY;
					rnd++;
				} else {
					_matrix[i][j] = loadMatrix[rnd];
					rnd++;
				}
			}
		}
	}

	private function pointInMatrix(x:int, y:int):Boolean {
		return x >= 0 && x < MATRIX_WIDTH && y >= 0 && y < MATRIX_HEIGHT;
	}
}
}