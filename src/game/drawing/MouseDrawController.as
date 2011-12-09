package game.drawing {
	import flash.display.Shape;
import flash.events.Event;

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
	private var _matrixPath:Vector.<Point>;
	private var _originPath:Vector.<Point>;

	private var _pathShapes:Vector.<Sprite>;

	private var _currentMousePoint:Point;

	private var _container:Sprite;
	private var _drawingContainer:Sprite;
//		private var _rectanglesContainer:Sprite;

	private var _currentPathPart:Shape;

	private var _currentPoint:Point;

	private var _pathParts:Vector.<Shape>;
//		private var _rectangles:Vector.<Shape>;

	private var _drawing:Boolean;

	public function MouseDrawController(container:Sprite, mapMatrix:MapMatrix) {
		_mapMatrix = mapMatrix;
		_drawing = false;
		_drawingContainer = new Sprite();
		_currentPoint = new Point();
		_container = container;
		_container.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		_container.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		_container.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		_container.addChild(_drawingContainer);
	}

	public function get tankPath():Vector.<Point> {
		return _matrixPath;
	}

	public function get currentMousePoint():Point { return _currentPoint; }

	public function getLastMovePoint():Point {
		if (_matrixPath && _matrixPath.length > 0) {
			return _matrixPath[_matrixPath.length-1];
		}
		return null;
	}

	public function startDrawTankPath():void {
		removePath();
		_matrixPath = new Vector.<Point>();
		createNewPathPart();
		_matrixPath.push(_mapMatrix.getMatrixPoint(new Point(_currentPoint.x, _currentPoint.y)));
		//_drawingContainer.graphics.moveTo(_currentMousePoint.x, _currentMousePoint.y);
		_drawing = true;
		_container.addEventListener(Event.ENTER_FRAME, onEnterFrame);
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
		drawPartRectangle(_currentPoint);
		_currentPathPart.graphics.moveTo(_currentPoint.x, _currentPoint.y);
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

	private function onMouseMove(event:MouseEvent):void {
		if (_drawing) {
			_currentPoint.x = event.stageX;
			_currentPoint.y = event.stageY;
		}
	}

	private function onEnterFrame(event:Event):void {
		var mPoint:Point = _mapMatrix.getMatrixPoint(_currentPoint);
		if (_drawing && _mapMatrix.isFreeCell(mPoint.x, mPoint.y)) {
			drawShapePathToCurrentPoint();
			if (newPoint(_currentPoint)) {
				addPointToPath(_currentPoint);
				createNewPathPart();
				dispatchEvent(new DrawingControllerEvent(DrawingControllerEvent.NEW_MOVE_POINT));
			}
		} else {
			stopDrawing();
		}
	}

	//refact this shit
	private function drawShapePathToCurrentPoint():void {
		if (!_drawing) { return; }
		var lastPoint:Point = (_pathShapes && _pathShapes.length > 0) ?
													new Point(_pathShapes[_pathShapes.length-1].x, _pathShapes[_pathShapes.length-1].y) : null;
		var newPathShape:Sprite;
		if (!lastPoint) {
			newPathShape = PathShape.createCircleShape();
			addNewPathShape(newPathShape);
		} else {
			var nowPoint:Point = new Point(_currentPoint.x, _currentPoint.y);
			var lineLength:Number = Point.distance(lastPoint, nowPoint);
			var tempPoint:Point;
			for (var i:int = 4; i < lineLength; i+= 4) {
				newPathShape = PathShape.createCircleShape();
				tempPoint = Point.interpolate(nowPoint, lastPoint, i / lineLength);
				newPathShape.x = tempPoint.x;
				newPathShape.y = tempPoint.y;
				addNewPathShape(newPathShape);
			}
		}
	}

	private function addNewPathShape(pathShape:Sprite):void {
		_drawingContainer.addChild(pathShape);
		if (!_pathShapes) { _pathShapes = new Vector.<Sprite>(); }
		_pathShapes.push(pathShape);
	}

	private function onMouseUp(event:MouseEvent):void {
		stopDrawing();
		if (_matrixPath) {
			dispatchEvent(new DrawingControllerEvent(DrawingControllerEvent.DRAWING_COMPLETE));
		}
	}

	private function stopDrawing():void {
		_container.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		_drawing = false;
	}

	private function newPoint(point:Point):Boolean {
		const matrixPoint:Point = _mapMatrix.getMatrixPoint(point);
		if (!_matrixPath || _matrixPath.length == 0) { return true; }
		return (matrixPoint.x != _matrixPath[_matrixPath.length-1].x ||
						matrixPoint.y != _matrixPath[_matrixPath.length-1].y);
	}

	private function addPointToPath(point:Point):void {
			_matrixPath.push(_mapMatrix.getMatrixPoint(point));
	}

	private function drawPoint(point:Point):void {
		if (_currentPathPart) {
			_currentPathPart.graphics.lineTo(point.x, point.y);
		}
	}

	private function removePath():void {
		if (_matrixPath) {
			if (_pathParts && _pathParts.length > 0) {
				for each (var part:Shape in _pathParts) {
					TweenMax.killTweensOf(part);
					_drawingContainer.removeChild(part);
				}
				_pathParts = null;
			}
			_matrixPath = null;
		}
	}

	private function onMouseDown(event:MouseEvent):void {
		_currentPoint.x = event.stageX;
		_currentPoint.y = event.stageY;
		dispatchEvent(new DrawingControllerEvent(DrawingControllerEvent.WANT_START_DRAW));
	}

	/*
	private function newPathAndShow():void {
		if (!_matrixPath || _matrixPath.length == 0) { return; }
		_drawingContainer.graphics.clear();
		_drawingContainer.graphics.lineStyle(2, 0x00ff00);
		_drawingContainer.graphics.moveTo(_matrixPath[0].x * cellWidth + cellWidth/2,
																			_matrixPath[0].y * cellWidth + cellWidth/2);
		for each (var point:Point in _matrixPath) {
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
