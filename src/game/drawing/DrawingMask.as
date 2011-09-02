package game.drawing {
	import game.GameController;
	import flash.display.Shape;
	import flash.geom.Point;
	import flash.display.Sprite;

	public class DrawingMask extends Sprite {
		private var _shapes:Vector.<Shape>;
		
		public function DrawingMask() {
			super();
		}
		
		public function get empty():Boolean {
			return !_shapes || _shapes.length == 0;
		}
		
		public function draw(path:Vector.<Point>):void {
			removeShapes();
			var loopShape:Shape;
			for each (var point:Point in path) {
				loopShape = new Shape();
				loopShape.graphics.beginFill(0xffffff);
				loopShape.graphics.drawRect(point.x * GameController.CELL,
													point.y * GameController.CELL,
													GameController.CELL, GameController.CELL);
				loopShape.graphics.endFill();
				addShape(loopShape);
				addChild(loopShape);
			}
		}
		
		public function shiftLast():void {
			if (_shapes && _shapes.length > 0) {
				removeShapeFromView(_shapes[0]);
				_shapes.shift();
			}
		}
		
		private function addShape(shape:Shape):void {
			if (!_shapes) { _shapes = new Vector.<Shape>(); }
			_shapes.push(shape);
		}
		
		private function removeShapeFromView(shape:Shape):void {
			if (contains(shape)) { removeChild(shape); }
		}
		
		private function removeShapes():void {
			if (_shapes && _shapes.length > 0) {
				for each (var shape:Shape in _shapes) {
					if (contains(shape)) { removeChild(shape); }
				}
			}
		}
	}
}
