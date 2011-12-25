
package menu {
import com.greensock.TweenMax;

import flash.events.Event;
import flash.display.Sprite;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;

import game.drawing.GunSlotsAdapter;
import game.events.SceneEvent;
import game.matrix.MapMatrix;
import game.tank.Tank;
import game.tank.TankVO;

import state.UserState;

public class TankPodium extends EventDispatcher implements IScene{
	private var _paper:GameBckg;

	private var _tank:Tank;

	private var _tankBases:Vector.<Sprite>;
	public static const VALID_TANK_BASES:Array = [TankBase1, TankBase2, EnemyBase1, EnemyBase2, EnemyBase3];

	private var _container:Sprite;

	private var _playBtn:NewGameBtn;

	private var _gunSlots:GunSlotsAdapter;

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
		createPlayBtn();
		createTankBaseBtns();
		_gunSlots = new GunSlotsAdapter(this);
	}

	public function get container():Sprite { return _container; }
	public function get tank():Tank { return _tank; }

	public function open():void {
		_closed = true;
		_container.addChild(_paper);
		_container.addChild(_tank);
	 for each (var tankBase:Sprite in _tankBases) {
		 _container.addChild(tankBase);
	 }
		addPlayBtn();
		addListeners();
	}

	public function remove():void {
		removePlayBtn();
		removeListeners();
		TweenMax.killTweensOf(_tank);
		_container.removeChild(_tank);
		_container.removeChild(_paper);
		for each (var tankBase:Sprite in _tankBases) {
			_container.removeChild(tankBase);
		}
		_closed = true;
	}

	/* Internal functions */

	private function addListeners():void {
		_tank.addEventListener(MouseEvent.ROLL_OVER, onTankRollOver);
	}
	
	private function removeListeners():void {
		_tank.removeEventListener(MouseEvent.ROLL_OVER, onTankRollOver);
	}

	private function onTankRollOver(event:MouseEvent):void {
		_gunSlots.show();
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

	private function createTankBaseBtns():void {
		_tankBases = new Vector.<Sprite>();
		var tempBase:Sprite;
		for (var i:int = 0; i < VALID_TANK_BASES.length; ++i) {
			tempBase = new VALID_TANK_BASES[i];
			_tankBases.push(tempBase);
			tempBase.y = _tank.originY + 100;
			tempBase.x = _tank.originX - 50 *(VALID_TANK_BASES.length-1) + i * 100;
			tempBase.addEventListener(MouseEvent.CLICK, onTankBaseClick);
			tempBase.addEventListener(MouseEvent.MOUSE_OVER, onTankBaseMouseOver);
			tempBase.addEventListener(MouseEvent.MOUSE_OUT, onTankBaseMouseOut);
		}
	}

	//fuck, but fast
	private function onTankBaseClick(event:MouseEvent):void {
		for (var i:int = 0; i < VALID_TANK_BASES.length; ++i) {
			//trace(Sprite(event.target)["constructor"]);
			if (Sprite(event.target)["constructor"] == VALID_TANK_BASES[i]) {
				_tank.updateBase(i);
			}
		}
	}
	private function onTankBaseMouseOver(event:MouseEvent):void {
		event.target["filters"] = [new GlowFilter()];
	}
	private function onTankBaseMouseOut(event:MouseEvent):void {
		event.target["filters"] = [];
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
