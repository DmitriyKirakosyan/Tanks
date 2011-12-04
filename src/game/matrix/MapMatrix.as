package game.matrix {
import flash.geom.Matrix;
import flash.geom.Rectangle;
	import flash.geom.Point;
	import game.GameController;
	import flash.display.Sprite;

public class MapMatrix {
		private var _matrix:Vector.<Vector.<uint>>;

		/* for debug (drawing web) */
		private var _container:Sprite;
		
		public static const MATRIX_WIDTH:int = 15;
		public static const MATRIX_HEIGHT:int = 15;
		
		public function MapMatrix(container:Sprite) {
			_container = container;
			createEmptyMatrix();
		}
		
		public function get matrix():Vector.<Vector.<uint>> {
			return _matrix;
		}
		
		public function getMatrixPoint(point:Point):Point{
			return new Point(int((point.x ) / GameController.CELL),
												int((point.y) / GameController.CELL));
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
			_matrix[x][y] = MatrixItemIds.EMPTY;
		}

		public function isFreeCell(mPoint:Point):Boolean {
			return _matrix[mPoint.x][mPoint.y] == MatrixItemIds.EMPTY;
		}

		public function remove():void {
		}

		public function createEmptyMatrix():void {
			_matrix = new Vector.<Vector.<uint>>();
			for (var i:int = 0; i < MATRIX_WIDTH; ++i) {
				_matrix.push(new Vector.<uint>());
				for (var j:int = 0; j < MATRIX_HEIGHT; ++j) {
					_matrix[i].push(MatrixItemIds.EMPTY);
				}
			}
		}
		
		public function createMatrix():void {

			for (var i:int = 0; i < _matrix.length; ++i) {
				for (var j:int = 0; j < MATRIX_HEIGHT; ++j) {
					if (i == int(MATRIX_WIDTH/2) && j == int(MATRIX_HEIGHT/2)) {
						_matrix[i][j] = MatrixItemIds.EMPTY;
					} else {
						_matrix[i][j] = Math.random() > .2 ?  MatrixItemIds.EMPTY :
																	Math.random() < .1 ? MatrixItemIds.STONE : MatrixItemIds.BRICKS;
					}
				}
			}
		}
	}
}