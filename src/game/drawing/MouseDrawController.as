package game.drawing {
	import flash.display.Shape;
	import game.events.DrawingControllerEvent;
	import flash.events.EventDispatcher;
	import com.greensock.TweenMax;
	import game.GameController;
	import game.matrix.MapMatrix;
	import flash.geom.Point;
	import flash.events.MouseEvent;
	import flash.display.Sprite;

	public class MouseDrawController extends EventDispatcher{
		private var _mapMatrix:MapMatrix;
		private var _path:Vector.<Point>;
		
		private var _currentMousePoint:Point;
		
		private var _container:Sprite;
		private var _drawingContainer:Sprite;
//		private var _rectanglesContainer:Sprite;
		
		private var _currentPathPart:Shape;
		
		private var _pathParts:Vector.<Shape>;
//		private var _rectangles:Vector.<Shape>;
		
		private var _drawing:Boolean;
		
		public function MouseDrawController(container:Sprite, mapMatrix:MapMatrix) {
			_mapMatrix = mapMatrix;
			_drawing = false;
			_drawingContainer = new Sprite();
			_container = container;
			_container.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			_container.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			_container.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			_container.addChild(_drawingContainer);
		}
		
		public function get tankPath():Vector.<Point> {
			return _path;
		}
		
		public function get currentMousePoint():Point { return _currentMousePoint; }
		
		public function getLastMovePoint():Point {
			if (_path && _path.length > 0) {
				return _path[_path.length-1];
			}
			return null;
		}
		
		public function startDrawTankPath():void {
			removePath();
			_path = new Vector.<Point>();
			createNewPathPart();
			_path.push(_mapMatrix.getMatrixPoint(new Point(_currentMousePoint.x, _currentMousePoint.y)));
			//_drawingContainer.graphics.moveTo(_currentMousePoint.x, _currentMousePoint.y);
			_drawing = true;
		}
		
		public function removePart():void {
			if (!_pathParts || _pathParts.length == 0) {
				trace("[MouseDrawingController.removePart] why no parts??");
				return;
			}
			const part:Shape = _pathParts[0];
			removePartFromContainer(part);
			_pathParts.shift();
		}

		public function remove():void {
			_currentMousePoint = null;
			removePath();
			_drawing = false;
		}
		
		/* Internal functions */
		
		private function createNewPathPart():void {
			if (!_pathParts) { _pathParts = new Vector.<Shape>(); }
			_currentPathPart = new Shape();
			drawPartRectangle(_currentMousePoint);
			_currentPathPart.graphics.moveTo(_currentMousePoint.x, _currentMousePoint.y);
			_currentPathPart.graphics.lineStyle(2, 0x00ff00);
			_pathParts.push(_currentPathPart);

			_drawingContainer.addChild(_currentPathPart);
		}
		
		private function drawPartRectangle(point:Point):void {
			const mapPoint:Point = _mapMatrix.getMatrixPoint(point);
			const rectPoint:Point = new Point(mapPoint.x * cellWidth, mapPoint.y * cellWidth);
			_currentPathPart.graphics.beginFill(0x1fffff, .3);
			_currentPathPart.graphics.drawRoundRect(rectPoint.x, rectPoint.y, cellWidth, cellWidth, 1, 1);
			_currentPathPart.graphics.endFill();
		}
		
		private function drawRectangle():void {
			_container.graphics.beginFill(0xffffff, .0);
			_container.graphics.drawRect(0, 0, 
													MapMatrix.MATRIX_WIDTH * cellWidth,
													MapMatrix.MATRIX_HEIGHT * cellWidth);	
			_container.graphics.endFill();
		}
		
		private function onMouseMove(event:MouseEvent):void {
			if (_drawing) {
				const point:Point = new Point(event.stageX, event.stageY);
				_currentMousePoint = point;
				drawPoint(point);
				if (newPoint(point)) {
					addPointToPath(point);
					createNewPathPart();
					dispatchEvent(new DrawingControllerEvent(DrawingControllerEvent.NEW_MOVE_POINT));
				}
			}
		}
		
		private function newPoint(point:Point):Boolean {
			const matrixPoint:Point = _mapMatrix.getMatrixPoint(point);
			if (!_path || _path.length == 0) { return true; }
			return (matrixPoint.x != _path[_path.length-1].x ||
							matrixPoint.y != _path[_path.length-1].y);
		}
		
		private function addPointToPath(point:Point):void {
				_path.push(_mapMatrix.getMatrixPoint(point));
		}
		
		private function drawPoint(point:Point):void {
			if (_currentPathPart) {
				_currentPathPart.graphics.lineTo(point.x, point.y);
			}
		}
		
		private function removePath():void {
			if (_path) {
				if (_pathParts && _pathParts.length > 0) {
					for each (var part:Shape in _pathParts) {
						TweenMax.killTweensOf(part);
						_drawingContainer.removeChild(part);
					}
					_pathParts = null;
				}
				_path = null;
			}
		}
		
		private function onMouseDown(event:MouseEvent):void {
			_currentMousePoint = new Point(event.stageX, event.stageY);
			dispatchEvent(new DrawingControllerEvent(DrawingControllerEvent.WANT_START_DRAW));
		}
		
		private function onMouseUp(event:MouseEvent):void {
			if (_path) {
				_drawing = false;
				dispatchEvent(new DrawingControllerEvent(DrawingControllerEvent.DRAWING_COMPLETE));
			}
		}
		
		/*
		private function newPathAndShow():void {
			if (!_path || _path.length == 0) { return; }
			_drawingContainer.graphics.clear();
			_drawingContainer.graphics.lineStyle(2, 0x00ff00);
			_drawingContainer.graphics.moveTo(_path[0].x * cellWidth + cellWidth/2, 
																				_path[0].y * cellWidth + cellWidth/2);
			for each (var point:Point in _path) {
				_drawingContainer.graphics.lineTo(point.x * cellWidth + cellWidth/2,
																					point.y * cellWidth + cellWidth/2);
			}
			TweenMax.to(_drawingContainer, .08, {alpha: 1});
		}
		 * 
		 */

		private function removePartFromContainer(part:Shape):void {
			TweenMax.to(part, .4, {alpha : 0, 
									onComplete : function():void { _drawingContainer.removeChild(part); }});
		}
		
		private function get cellWidth():int { return GameController.CELL; }

	}
}
