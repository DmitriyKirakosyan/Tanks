
package menu {
import com.greensock.TimelineMax;
import com.greensock.TweenMax;
import com.greensock.easing.Linear;

import flash.display.Shape;

import flash.display.Sprite;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;

import game.GameController;
import game.events.SceneEvent;

import game.matrix.MapMatrix;

import game.tank.Tank;
import game.tank.TankVO;

public class TankPodium extends EventDispatcher implements IScene{
	private var _tank:Tank;
	private var _dragTank:Boolean;
	private var _container:Sprite;

	public function TankPodium(container:Sprite) {
		_tank = new Tank(new TankVO());
		_tank.init();
		_container = container;
		_tank.x = MapMatrix.MATRIX_WIDTH/2;
		_tank.y = MapMatrix.MATRIX_HEIGHT/2;
	}

	public function open():void {
		trace("menu open");
		_container.addChild(_tank);
		_tank.rotation = 0;
		rotateTank();
		addListeners();
	}

	public function remove():void {
		removeListeners();
		TweenMax.killTweensOf(_tank);
		_container.removeChild(_tank);
	}

	/* Internal functions */

	private function addListeners():void {
		_container.addEventListener(MouseEvent.MOUSE_DOWN, onTankMouseDown);
		_container.addEventListener(MouseEvent.MOUSE_UP, onTankMouseUp);
		_container.addEventListener(MouseEvent.MOUSE_MOVE, onTankMouseMove);
		//_container.addEventListener(MouseEvent.CLICK, onClick);
	}

	private function removeListeners():void {
		_container.removeEventListener(MouseEvent.CLICK, onClick);
	}

	private function onTankMouseDown(event:MouseEvent):void {
		if (_tank.hitTestPoint(event.stageX, event.stageY)) {
			_dragTank = true;
		}
	}
	private function onTankMouseUp(event:MouseEvent):void {
			_dragTank = false;
	}

	private function onTankMouseMove(event:MouseEvent):void {
			if (_dragTank) {
				_tank.originX = event.stageX;
			}
	}

	private function rotateTank():void {
		var timeline:TimelineMax = new TimelineMax({repeat : -1});
		timeline.append(new TweenMax(_tank, 1.6, { rotation : 180, ease : Linear.easeNone, onComplete : function():void {_tank.rotation = -180;}}));
		timeline.append(new TweenMax(_tank,  1.6, { rotation : 0 , ease : Linear.easeNone}));
	}

	private function onClick(event:MouseEvent):void {
		_container.removeEventListener(MouseEvent.CLICK, onClick);
		dispatchEvent(new SceneEvent(SceneEvent.WANT_REMOVE));
	}

}
}
