
package menu {
import com.greensock.TimelineMax;
import com.greensock.TweenMax;
import com.greensock.easing.Linear;

import flash.display.Sprite;
import flash.events.MouseEvent;

import game.GameController;

import game.matrix.MapMatrix;

import game.tank.Tank;

public class TankPodium implements IScene{
	private var _tank:Tank;
	private var _container:Sprite;

	public function TankPodium(container:Sprite) {
		_tank = new Tank();
		_container = container;
		_tank.x = MapMatrix.MATRIX_WIDTH/2;
		_tank.y = MapMatrix.MATRIX_HEIGHT/2;
		_container.addChild(_tank);
		_container.addEventListener(MouseEvent.CLICK, onClick);
		rotateTank();
	}

	public function open():void {
	}

	public function remove():void {
		TweenMax.killTweensOf(_tank);
		_container.removeChild(_tank);
		_tank = null;
	}

	private function rotateTank():void {
		var timeline:TimelineMax = new TimelineMax({repeat : -1});
		timeline.append(new TweenMax(_tank, 1.6, { rotation : 180, ease : Linear.easeNone, onComplete : function():void {_tank.rotation = -180;}}));
		timeline.append(new TweenMax(_tank,  1.6, { rotation : 0 , ease : Linear.easeNone}));
	}

	private function onClick(event:MouseEvent):void {
		_container.removeEventListener(MouseEvent.CLICK, onClick);
		remove();
		new GameController(_container);
	}

}
}
