
package menu {
import com.greensock.TimelineMax;
import com.greensock.TweenMax;
import com.greensock.easing.Linear;

import flash.display.Sprite;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;
import flash.filters.BlurFilter;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

import game.events.SceneEvent;

import game.matrix.MapMatrix;

import game.tank.Tank;
import game.tank.TankVO;

import state.UserState;

public class TankPodium extends EventDispatcher implements IScene{
	private var _paper:PaperView;
	private var _tank:Tank;
	private var _defaultTankPoint:Point;
	private var _dragBackTween:TweenMax;
	private var _dragTank:Boolean;
	private var _container:Sprite;

	private var _playBtn:Sprite;
	private var _playBtnTxt:TextField;

	public function TankPodium(container:Sprite) {
		_paper = new PaperView();
		_tank = new Tank(new TankVO());
		_container = container;
		_tank.x = MapMatrix.MATRIX_WIDTH/2;
		_tank.y = MapMatrix.MATRIX_HEIGHT/2;
		_defaultTankPoint = new Point(_tank.x, _tank.y);
		createPlayBtn()
	}

	public function open():void {
		trace("menu open");
		_container.addChild(_paper);
		_container.addChild(_tank);
		_tank.rotation = 0;
		rotateTank();
		addPlayBtn();
		addListeners();
	}

	public function remove():void {
		removePlayBtn();
		removeListeners();
		TweenMax.killTweensOf(_tank);
		_container.removeChild(_tank);
		_container.removeChild(_paper);
	}

	/* Internal functions */

	private function addListeners():void {
		_container.addEventListener(MouseEvent.MOUSE_DOWN, onTankMouseDown);
		_container.addEventListener(MouseEvent.MOUSE_UP, onTankMouseUp);
		_container.addEventListener(MouseEvent.MOUSE_MOVE, onTankMouseMove);
	}
	
	private function removeListeners():void {
		_container.removeEventListener(MouseEvent.MOUSE_DOWN, onTankMouseDown);
		_container.removeEventListener(MouseEvent.MOUSE_UP, onTankMouseUp);
		_container.removeEventListener(MouseEvent.MOUSE_MOVE, onTankMouseMove);
	}

	private function createPlayBtn():void {
		_playBtn = new Sprite();
		_playBtn.graphics.beginFill(0xafafaf, .5);
		_playBtn.graphics.drawRect(-20, -20, 40, 40);
		_playBtn.x = 300;
		_playBtn.y = 100;
		_playBtnTxt = new TextField();
		_playBtnTxt.x = -10;
		_playBtnTxt.y = -10;
		_playBtnTxt.text = "play";
		_playBtnTxt.selectable = false;
		_playBtnTxt.autoSize = TextFieldAutoSize.LEFT;
		_playBtnTxt.mouseEnabled = false;
		_playBtn.addChild(_playBtnTxt);
		_playBtn.addEventListener(MouseEvent.MOUSE_OVER, onPlayBtnMouseOver);
		_playBtn.addEventListener(MouseEvent.MOUSE_OUT, onPlayBtnMouseOut);
		_playBtn.addEventListener(MouseEvent.CLICK, onPlayBtnClick);
	}

	private function onPlayBtnMouseOver(event:MouseEvent):void {
		TweenMax.to(_playBtn, .4, {glowFilter:{color:0x91e600, alpha:1, blurX:10, strength : 4, blurY:10}});
	}
	private function onPlayBtnMouseOut(event:MouseEvent):void {
		TweenMax.to(_playBtn, 4., {glowFilter:{color:0x91e600, alpha:0, strength : 10, blurX:300, blurY:300}});
	}

	private function onPlayBtnClick(event:MouseEvent):void {
		UserState.instance.tankVO.tankBase = _tank.vo.tankBase;
		switchScene();
	}

	private function addPlayBtn():void {
		_container.addChild(_playBtn);
	}
	private function removePlayBtn():void {
		_container.removeChild(_playBtn);
	}

	private function onTankMouseDown(event:MouseEvent):void {
		if (_tank.hitTestPoint(event.stageX, event.stageY)) {
			_dragTank = true;
			if (_dragBackTween) { _dragBackTween.kill(); }
		}
	}
	private function onTankMouseUp(event:MouseEvent):void {
		_dragTank = false;
		if (Math.abs(_tank.x - _defaultTankPoint.x) < .6) {
			if (_tank.x != _defaultTankPoint.x) {
				_dragBackTween = new TweenMax(_tank, .4, {x : _defaultTankPoint.x});
			}
		} else {
			switchTanks();
		}
	}

	private function switchTanks():void {
		const coef:int = _tank.x > _defaultTankPoint.x ? 1 : -1;
		TweenMax.killTweensOf(_tank.gun);
		TweenMax.killTweensOf(_tank.tankBase);
		TweenMax.to(_tank,  .3, {originX : _tank.originX + coef * 60, scaleX : 4, scaleY : .1, blurFilter:{blurX:20}, alpha : 0, ease:Linear.easeOut, onComplete : onTankShiftComplete});
	}

	private function onTankShiftComplete():void {
		if (_container.contains(_tank)) { _container.removeChild(_tank); }
		const vo:TankVO = new TankVO();
		const point:Point = new Point(_tank.x,  _tank.y);
		vo.tankBase = _tank.vo.tankBase == 0 ? 1 : 0;
		_tank = new Tank(vo);
		const distance:Number = Math.abs(_defaultTankPoint.x -point.x);
		_tank.x = point.x < _defaultTankPoint.x ? point.x + 2*distance :point.x - 2 * distance;
		_tank.alpha = 0;
		_tank.filters = [new BlurFilter(20)];
		_tank.scaleX = 4;
		_tank.scaleY = .1; _tank.y = point.y;
		_container.addChild(_tank);
		TweenMax.to(_tank,  .3, {x : _defaultTankPoint.x, scaleX : 1, scaleY : 1, alpha : 1, ease:Linear.easeIn, blurFilter:{blurX:0}, onComplete : function():void { _tank.filters = []; }});
	}

	private function onTankMouseMove(event:MouseEvent):void {
			if (_dragTank) {
				_tank.originX = event.stageX;
			}
	}

	private function rotateTank():void {
		var timeline:TimelineMax = new TimelineMax({repeat : -1});
		timeline.insert(new TweenMax(_tank.gun, 1.6, { rotation : 180, ease : Linear.easeNone, onComplete : function():void {_tank.gun.rotation = -180;}}));
		const length:Number = timeline.duration;
		timeline.insert(new TweenMax(_tank.gun,  1.6, { rotation : 0 , ease : Linear.easeNone}), length);
		timeline.insert(new TweenMax(_tank.tankBase,  1.6, { rotation : 0 , ease : Linear.easeNone}), length);
		timeline.insert(new TweenMax(_tank.tankBase, 1.6, { rotation : 180, ease : Linear.easeNone, onComplete : function():void {_tank.tankBase.rotation = -180;}}));
	}

	private function switchScene():void {
		dispatchEvent(new SceneEvent(SceneEvent.WANT_REMOVE));
	}

}
}
