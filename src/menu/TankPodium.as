
package menu {
import com.bit101.components.Text;
import com.greensock.TweenMax;

import flash.display.Shape;

import flash.events.Event;
import flash.display.Sprite;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;
import flash.filters.BlurFilter;
import flash.filters.GlowFilter;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

import game.GameController;

import game.drawing.GunSlotsAdapter;
import game.events.SceneEvent;
import game.mapObjects.ObjectsHp;
import game.matrix.MapMatrix;
import game.tank.Tank;
import game.tank.TankVO;

import mx.core.TextFieldAsset;

import state.UserState;

public class TankPodium extends EventDispatcher implements IScene{
	private var _paper:GameBckg;

	private var _tank:Tank;

	private var _tankBases:Vector.<Sprite>;
	public static const VALID_TANK_BASES:Array = [TankBase1, TankBase2, EnemyBase1, EnemyBase2, EnemyBase3];
	public static const VALID_TANK_BASES_FOR_PLAYER = [TankBase1, TankBase2];

	private const SCORE_NEED_FOR_TANK_UNLOCK:int = 50;

	private var _container:Sprite;

	private var _playBtn:NewGameBtn;

	private var _gunSlots:GunSlotsAdapter;

	private var _closed:Boolean;

	private var _lock:Sprite;

	private var _tutorialCounter:int;
	private const MAX_TUTORIAL_COUNT:int = 2;
	private var _tutorialView:Sprite;

	public function TankPodium(container:Sprite) {
		_closed = true;
		_tutorialCounter = 0;
		_container = container;
		_paper = new GameBckg();
		_tank = Tank.createPlayerTank(new TankVO());
		_tank.liveTab.visible = false;
		_tank.liveTabBckg.visible = false;
		_tank.x = (MapMatrix.MATRIX_WIDTH - _tank.width/32)/2;
		_tank.y = 10.5;//MapMatrix.MATRIX_HEIGHT/2;
		createPlayBtn();
		createTankBaseBtns();
		createTutorialView();
		_gunSlots = new GunSlotsAdapter(this);
	}

	public function get container():Sprite { return _container; }
	public function get tank():Tank { return _tank; }

	public function open():void {
		tank.vo.speed = TankVO.FIRST_SPEED;
		tank.vo.hp = ObjectsHp.PLAYER;
		_closed = true;
		_container.addChild(_paper);
		_container.addChild(_tank);
	 for each (var tankBase:Sprite in _tankBases) {
		 _container.addChild(tankBase);
	 }
		addPlayBtn();
		addListeners();
		checkForUnlockTank();
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
		if (_container.contains(_gunSlots)) { _container.removeChild(_gunSlots); }
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

	private function checkForUnlockTank():void {
		if (_tankBases.length>0 && UserState.instance.allScore() >= SCORE_NEED_FOR_TANK_UNLOCK) {
			var tempBase:Sprite = _tankBases[1];
			tempBase.addEventListener(MouseEvent.CLICK, onTankBaseClick);
			tempBase.addEventListener(MouseEvent.MOUSE_OVER, onTankBaseMouseOver);
			tempBase.addEventListener(MouseEvent.MOUSE_OUT, onTankBaseMouseOut);
			if (_lock && tempBase.contains(_lock)) { tempBase.removeChild(_lock); }
		}
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
		for (var i:int = 0; i < VALID_TANK_BASES_FOR_PLAYER.length; ++i) {
			tempBase = new VALID_TANK_BASES_FOR_PLAYER[i];
			_tankBases.push(tempBase);
			tempBase.y = _tank.originY + 100;
			tempBase.x = _tank.originX - 50 *(VALID_TANK_BASES_FOR_PLAYER.length-1) + i * 100;
			if (i == 0) {
				tempBase.addEventListener(MouseEvent.CLICK, onTankBaseClick);
				tempBase.addEventListener(MouseEvent.MOUSE_OVER, onTankBaseMouseOver);
				tempBase.addEventListener(MouseEvent.MOUSE_OUT, onTankBaseMouseOut);
			} else {
				_lock = new Lock();
				addTextToLock();
				tempBase.addChild(_lock);
			}
		}
	}

	private function createTutorialView():void {
		_tutorialView = new Sprite();
		var leftView:Sprite = new Tutorial2();
		var rightView:Sprite = new Tutorial1();
		leftView.x = -leftView.width/4+10;
		leftView.y = -leftView.height/4+10;
		rightView.x = rightView.width/4;
		rightView.y = rightView.height/4 +10;
		leftView.filters = [new GlowFilter(0)];
		rightView.filters = [new GlowFilter(0)];
		_tutorialView.addChild(rightView);
		_tutorialView.addChild(leftView);
		_tutorialView.x = _tutorialView.width/2;
		_tutorialView.y = _tutorialView.height/2;
		var bkg:Shape = new Shape();
		bkg.graphics.beginFill(0, .7);
		var width:Number = MapMatrix.MATRIX_WIDTH*GameController.CELL;
		var height:Number = MapMatrix.MATRIX_WIDTH*GameController.CELL;
		bkg.graphics.drawRect(-width/2, -height/2, width, height);
		bkg.graphics.endFill();
		bkg.filters = [new BlurFilter()];
		bkg.x = 5;
		bkg.y = 29;
		_tutorialView.addChildAt(bkg, 0);
	}

	private function addTextToLock():void {
		if (_lock) {
			var tf:TextField = new TextField();
			tf.selectable = false;
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.text = "50 points";
			tf.x = -tf.textWidth/2;
			tf.y = 26;
			tf.textColor = 0x0fafdf;
			_lock.addChild(tf);
		}
	}

	//fuck, but fast
	private function onTankBaseClick(event:MouseEvent):void {
		for (var i:int = 0; i < VALID_TANK_BASES.length; ++i) {
			//trace(Sprite(event.target)["constructor"]);
			if (Sprite(event.target)["constructor"] == VALID_TANK_BASES_FOR_PLAYER[i]) {
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
		if (_tutorialCounter < 2) {
			_tutorialCounter++;
			_container.addChild(_tutorialView);
			_tutorialView.addEventListener(MouseEvent.CLICK, onTutorialClick);
		} else {
			startGame();
		}
	}
	private function onTutorialClick(event:MouseEvent):void {
		_tutorialView.removeEventListener(MouseEvent.CLICK, onTutorialClick);
		_container.removeChild(_tutorialView);
		startGame();
	}

	private function startGame():void {
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
