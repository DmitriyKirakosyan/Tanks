
package menu {
import flash.events.Event;
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
import game.tank.weapon.TankGun;
import game.tank.TankVO;

//import mx.containers.TabNavigator;

import state.UserState;

public class TankPodium extends EventDispatcher implements IScene{
	private var _paper:GameBckg;

	//tank switching
	private var _tank:Tank;

	//weapon switching
	private var _weapon:TankGun;

	private var _defaultTankPoint:Point;

	private var _defaultWeaponPoint:Point;

	private var _container:Sprite;

	private var _playBtn:NewGameBtn;

	private var _closed:Boolean;

	public function TankPodium(container:Sprite) {
		_closed = true;
		_container = container;
		_paper = new GameBckg();
		_tank = Tank.createPlayerTank(new TankVO());
		_tank.liveTab.visible = false;
		_tank.liveTabBckg.visible = false;
		_tank.x = (MapMatrix.MATRIX_WIDTH - _tank.width/32)/2;
		_tank.y = 10.5;//MapMatrix.MATRIX_HEIGHT/2;
		createWeapon();
		_defaultTankPoint = new Point(_tank.x, _tank.y);
		_defaultWeaponPoint = new Point(_weapon.x, _weapon.y);
		createPlayBtn();
	}

	public function open():void {
		_closed = true;
		_container.addChild(_paper);
		_container.addChild(_tank);
		_container.addChild(_weapon);

		addPlayBtn();
		addListeners();
	}

	public function remove():void {
		removePlayBtn();
		removeListeners();
		TweenMax.killTweensOf(_tank);
		_container.removeChild(_tank);
		_container.removeChild(_weapon);
		_container.removeChild(_paper);
		_closed = true;
	}

	/* Internal functions */

	private function addListeners():void {
		_tank.addEventListener(MouseEvent.ROLL_OVER, onTankRollOver);
		_tank.addEventListener(MouseEvent.ROLL_OUT, onTankRollOut);
	}
	
	private function removeListeners():void {
		_tank.removeEventListener(MouseEvent.ROLL_OVER, onTankRollOver);
		_tank.removeEventListener(MouseEvent.ROLL_OVER, onTankRollOut);
	}

	private function onTankRollOver(event:MouseEvent):void {
		TweenMax.to(_tank.tankBase, .3, {blurFilter:{blurX:10, blurY:10}});
		//_tank.tankBase.filters = [new BlurFilter(10,10)];
	}
	private function onTankRollOut(event:MouseEvent):void {
		TweenMax.to(_tank.tankBase, .3, {blurFilter:{blurX:0, blurY:0}});
		//_tank.tankBase.filters = [];
	}

	private function createPlayBtn():void {
		_playBtn = new NewGameBtn();
		_playBtn.buttonMode = true;
		_playBtn.x = 300;
		_playBtn.y = 350;
		_playBtn.gotoAndStop(1);
		_playBtn.addEventListener(MouseEvent.MOUSE_OVER, onPlayBtnMouseOver);
		_playBtn.addEventListener(MouseEvent.MOUSE_OUT, onPlayBtnMouseOut);
		_playBtn.addEventListener(MouseEvent.CLICK, onPlayBtnClick);
		
	}

	private function createWeapon():void {
		_weapon = new TankGun();
		_weapon.y = _tank.originY + 100;
		_weapon.x = _tank.originX;
	}

	private function onPlayBtnMouseOver(event:MouseEvent):void {
		if (_playBtn.hasEventListener(Event.ENTER_FRAME)) {
			_playBtn.removeEventListener(Event.ENTER_FRAME, animationNext);
			_playBtn.removeEventListener(Event.ENTER_FRAME, animationPrev);
		}
		_playBtn.addEventListener(Event.ENTER_FRAME, animationNext);
	}
	private function onPlayBtnMouseOut(event:MouseEvent):void {
		if (_playBtn.hasEventListener(Event.ENTER_FRAME)) {
			_playBtn.removeEventListener(Event.ENTER_FRAME, animationNext);
			_playBtn.removeEventListener(Event.ENTER_FRAME, animationPrev);
		}
		_playBtn.addEventListener(Event.ENTER_FRAME, animationPrev);
	}
	private function animationNext(event:Event):void {
		_playBtn.nextFrame();
	}
	private function animationPrev(event:Event):void {
		_playBtn.prevFrame();
	}

	private function onPlayBtnClick(event:MouseEvent):void {
		UserState.instance.tankVO = _tank.vo.getClone();
		switchScene();
	}

	private function addPlayBtn():void {
		_container.addChild(_playBtn);
	}
	private function removePlayBtn():void {
		_container.removeChild(_playBtn);
	}

	private function switchScene():void {
		dispatchEvent(new SceneEvent(SceneEvent.WANT_REMOVE));
	}

}
}
