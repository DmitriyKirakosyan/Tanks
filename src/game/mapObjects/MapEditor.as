/**
 * User: dima
 * Date: 15/11/11
 * Time: 2:25 PM
 */
package game.mapObjects {
import com.adobe.serialization.json.JSON;

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.net.FileReference;

import game.mapObjects.MapObject;
import game.matrix.MapMatrix;

public class MapEditor {
	private var _objectsController:MapObjectsController;
	private var _container:Sprite;

	private var _draggingContainer:Sprite;
	private var _mapMatrix:MapMatrix;

	private var _draggingObject:MapObject;

	public function MapEditor(container:Sprite, objectsController:MapObjectsController, mapMatrix:MapMatrix) {
		super();
		_objectsController = objectsController;
		_mapMatrix = mapMatrix;
		_container = container;
		_draggingContainer = new Sprite();
	}

	public function takeBrick():void {
		takeObject(new Brick(new Point(0, 0)));
	}

	public function takeStone():void {
		takeObject(new Stone(new Point(0, 0)));
	}

	public function saveMap():void {
		var fileReference:FileReference = new FileReference();
		fileReference.save(JSON.encode(_mapMatrix.matrix), "map");
	}

	/* Internal functions */

	private function takeObject(object:MapObject):void {
		_draggingObject = object;
		_container.addChild(_draggingContainer);
		_draggingContainer.addChild(_draggingObject);
		_draggingObject.visible = false;
		_container.addEventListener(MouseEvent.CLICK, onClick);
		_container.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
	}

	private function onMouseMove(event:MouseEvent):void {
		if (_draggingObject) {
			if (!_draggingObject.visible) {
				_draggingObject.visible = true;
			}
			_draggingObject.originX = event.stageX;
			_draggingObject.originY = event.stageY;
		}
	}

	private function onClick(event:MouseEvent):void {
		_container.removeEventListener(MouseEvent.CLICK, onClick);
		_container.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		_container.removeChild(_draggingContainer);
		sendObjectToObjectsController();
	}

	private function sendObjectToObjectsController():void {
		if (_draggingObject is Brick) {
			_objectsController.putBrick(_draggingObject as Brick);
		} else if (_draggingObject is Stone) {
			_objectsController.putStone(_draggingObject as Stone);
		}
	}
}
}
