/**
 * User: dima
 * Date: 15/11/11
 * Time: 2:25 PM
 */
package game.mapObjects {
import com.adobe.serialization.json.JSON;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flash.net.FileFilter;
import flash.net.FileReference;

import game.mapObjects.MapObject;
import game.matrix.MapMatrix;

public class MapEditor {
	private var _objectsController:MapObjectsController;
	private var _container:Sprite;

	private var _draggingContainer:Sprite;
	private var _mapMatrix:MapMatrix;
    private var _fileRef:FileReference;
	private var _xmlMap:XML;

	private var _cantPutFilter:GlowFilter = new GlowFilter();

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
    public function loadMap():void {
        _fileRef = new FileReference();
        _fileRef.addEventListener(Event.SELECT, onFileSelected);
        var textTypeFilter:FileFilter = new FileFilter("XML Files (*.xml)", "*.xml");
        _fileRef.browse([textTypeFilter]);
    }
	public function saveMap():void {
		saveMapInXML();
		var fileReference:FileReference = new FileReference();
		fileReference.save(_xmlMap, "map.xml");
	}
	/* Internal functions */
    private function onFileSelected(event:Event):void {
        _fileRef.removeEventListener(Event.SELECT, onFileSelected);
        _fileRef.addEventListener(Event.COMPLETE, onLoadComplete);
		_fileRef.load();
		trace("start load");
    }

    private function onLoadComplete(event:Event):void {
       _fileRef.removeEventListener(Event.COMPLETE, onLoadComplete);
       _xmlMap = new XML(_fileRef.data);
        parseXML();
    }

	private function parseXML():void {
		var objects:String = _xmlMap.MAP_OBJECTS;
		var mapObjects:Array = new Array;
		mapObjects = objects.split(",");
		_mapMatrix.createLoadMatrix(mapObjects);
		_objectsController.resetObjects();
	}

	private function saveMapInXML():void
	{
		//JSON.encode(_mapMatrix.matrix)
		_xmlMap = new XML(<LEVEL></LEVEL>);
		_xmlMap.BRICKS = _objectsController.bricks.length;
		_xmlMap.STONES = _objectsController.stones.length;
		_xmlMap.MAP_OBJECTS = _mapMatrix.matrix;
		trace(_xmlMap);
	}
	
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
			checkAccessForPut();
		}
	}

	private function checkAccessForPut():void {
		if (!_mapMatrix.isFreeCell(int(_draggingObject.x + .5), int(_draggingObject.y + .5))) {
			if (_draggingObject.filters.length == 0) { trace("filter"); _draggingObject.filters = [_cantPutFilter]; }
		} else if (_draggingObject.filters.length > 0) {
			_draggingObject.filters = [];
		}
	}

	private function onClick(event:MouseEvent):void {
		if (_draggingObject.originY > 100) {
			sendObjectToObjectsController();
		} else {
			_container.removeEventListener(MouseEvent.CLICK, onClick);
			_container.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			_container.removeChild(_draggingContainer);
			_draggingContainer.removeChild(_draggingObject);
		}
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
