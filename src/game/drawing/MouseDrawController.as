package game.drawing {

import com.greensock.easing.Elastic;

import flash.filters.BlurFilter;
import flash.filters.GlowFilter;

import game.tank.weapon.TankGunController;
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
	private var _pathOfMatrixPoints:Vector.<Point>;
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
	private var _arrowAngle:Number;

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
		return _pathOfMatrixPoints;
	}

	public function get currentMousePoint():Point { return _currentPoint; }

	public function getLastMovePoint():Point {
		if (_pathOfMatrixPoints && _pathOfMatrixPoints.length > 0) {
			return _pathOfMatrixPoints[_pathOfMatrixPoints.length-1];
		}
		return null;
	}

	public function startDrawTankPath():void {
		removePath();
		_pathOfMatrixPoints = new Vector.<Point>();
		createNewPathPart();
		_pathOfMatrixPoints.push(_mapMatrix.getMatrixPoint(new Point(_currentPoint.x, _currentPoint.y)));
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
		var numShapesForRemove:int = 0;
		for each (var pathShape:PathShape in _pathShapes) {
			if (part.hitTestPoint(pathShape.x,  pathShape.y)) {
				numShapesForRemove++;
				removePathShapeFromContainer(pathShape);
			} else { break; }
		}
		_pathShapes.splice(0, numShapesForRemove);

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
		_currentPathPart.graphics.beginFill(0x1fffff, .1);
		_currentPathPart.graphics.drawRoundRect(rectPoint.x, rectPoint.y, cellWidth, cellWidth, 1, 1);
		_currentPathPart.graphics.endFill();
		//_currentPathPart.filters = [new BlurFilter(15, 15, 6), new GlowFilter(0xffffff)];
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
	
	private function getAngle(arrow:Sprite):Number {
			var dx:Number = arrow.x - _container.mouseX;
			var dy:Number = arrow.y - _container.mouseY;
			var angle:Number = Math.atan2(dy, dx)*180/Math.PI;
			return angle;
	}
	//refact this shit
	//TODO баг с исчезанием стрелок под конец пути, проявляется во время стрельбы. 
	//Стрелки прикольно выглядят когда убираешь закраску квадаров движения
	private function drawShapePathToCurrentPoint():void {
		if (!_drawing) { return; }
		var lastPoint:Point = (_pathShapes && _pathShapes.length > 0) ?
													new Point(_pathShapes[_pathShapes.length-1].x, _pathShapes[_pathShapes.length-1].y) : null;
		var newPathShape:Sprite;
		if (!lastPoint) {
			newPathShape = PathShape.createCircleShape();
			addNewPathShape(newPathShape);
			newPathShape.x = _currentPoint.x;
			newPathShape.y = _currentPoint.y;
			_arrowAngle = getAngle(newPathShape);
			newPathShape.rotation = 90 + _arrowAngle;
		} else {
			var nowPoint:Point = new Point(_currentPoint.x, _currentPoint.y);
			var lineLength:Number = Point.distance(lastPoint, nowPoint);
			var tempPoint:Point;
			for (var i:int = 20; i < lineLength; i+= 20) {
				newPathShape = PathShape.createCircleShape();
				tempPoint = Point.interpolate(nowPoint, lastPoint, i / lineLength);
				newPathShape.x = tempPoint.x;
				newPathShape.y = tempPoint.y;
				_arrowAngle = getAngle(newPathShape);
				newPathShape.rotation = 90 + _arrowAngle;
				newPathShape.filters = [new GlowFilter(0x91e600, 1, 40, 40, 20)];
				TweenMax.to(newPathShape, .8, {glowFilter:{color:0x91e600, alpha:.5, blurX:4, strength : 4, blurY:4, ease : Elastic.easeOut}});
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
		if (_pathOfMatrixPoints) {
			dispatchEvent(new DrawingControllerEvent(DrawingControllerEvent.DRAWING_COMPLETE));
		}
	}

	private function stopDrawing():void {
		_container.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		_drawing = false;
	}

	private function newPoint(point:Point):Boolean {
		const matrixPoint:Point = _mapMatrix.getMatrixPoint(point);
		if (!_pathOfMatrixPoints || _pathOfMatrixPoints.length == 0) { return true; }
		return (matrixPoint.x != _pathOfMatrixPoints[_pathOfMatrixPoints.length-1].x ||
						matrixPoint.y != _pathOfMatrixPoints[_pathOfMatrixPoints.length-1].y);
	}

	private function addPointToPath(point:Point):void {
			_pathOfMatrixPoints.push(_mapMatrix.getMatrixPoint(point));
	}

	private function drawPoint(point:Point):void {
		if (_currentPathPart) {
			_currentPathPart.graphics.lineTo(point.x, point.y);
		}
	}

	private function removePath():void {
		if (_pathOfMatrixPoints) {
			if (_pathParts && _pathParts.length > 0) {
				for each (var part:Shape in _pathParts) {
					TweenMax.killTweensOf(part);
					_drawingContainer.removeChild(part);
				}
				_pathParts = null;
			}
			_pathOfMatrixPoints = null;
		}
		if (_pathShapes)  {
			for each (var pathShape:PathShape in _pathShapes) {
				_drawingContainer.removeChild(pathShape);
			}
			_pathShapes = null;
		}
	}

	private function onMouseDown(event:MouseEvent):void {
		_currentPoint.x = event.stageX;
		_currentPoint.y = event.stageY;
		dispatchEvent(new DrawingControllerEvent(DrawingControllerEvent.WANT_START_DRAW));
	}

	/*
	private function newPathAndShow():void {
		if (!_pathOfMatrixPoints || _pathOfMatrixPoints.length == 0) { return; }
		_drawingContainer.graphics.clear();
		_drawingContainer.graphics.lineStyle(2, 0x00ff00);
		_drawingContainer.graphics.moveTo(_pathOfMatrixPoints[0].x * cellWidth + cellWidth/2,
																			_pathOfMatrixPoints[0].y * cellWidth + cellWidth/2);
		for each (var point:Point in _pathOfMatrixPoints) {
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
	private function removePathShapeFromContainer(pathShape:PathShape):void {
		TweenMax.to(pathShape, .4, {alpha : 0,
								onComplete : function():void { _drawingContainer.removeChild(pathShape); }});
	}

	private function get cellWidth():int { return GameController.CELL; }

	}
}
