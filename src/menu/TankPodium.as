
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
	private var _tankSwitchLeftBtn:SwitchBtn;
	private var _tankSwitchRightBtn:SwitchBtn;

	//weapon switching
	private var _weapon:TankGun;
	private var _weaponSwitchLeftBtn:SwitchBtn;
	private var _weaponSwitchRightBtn:SwitchBtn;

	private var _defaultTankPoint:Point;
	private var _dragBackTankTween:TweenMax;
	private var _dragTank:Boolean;

	private var _defaultWeaponPoint:Point;
	private var _dragBackWeaponTween:TweenMax;
	private var _dragWeapon:Boolean;

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
		createTankSwitchBtns();
		createWeapon();
		createWeaponSwitchBtns();
		_defaultTankPoint = new Point(_tank.x, _tank.y);
		_defaultWeaponPoint = new Point(_weapon.x, _weapon.y);
		createPlayBtn();
	}

	public function open():void {
		_closed = true;
		_container.addChild(_paper);

		_container.addChild(_tank);
		_container.addChild(_tankSwitchLeftBtn);
		_container.addChild(_tankSwitchRightBtn);

		_container.addChild(_weapon);
		_container.addChild(_weaponSwitchLeftBtn);
		_container.addChild(_weaponSwitchRightBtn);

		addPlayBtn();
		addListeners();
	}

	public function remove():void {
		removePlayBtn();
		removeListeners();
		TweenMax.killTweensOf(_tank);
		_container.removeChild(_tank);
		_container.removeChild(_tankSwitchLeftBtn);
		_container.removeChild(_tankSwitchRightBtn);

		_container.removeChild(_weapon);
		_container.removeChild(_weaponSwitchLeftBtn);
		_container.removeChild(_weaponSwitchRightBtn);

		_container.removeChild(_paper);
		_closed = true;
	}

	/* Internal functions */

	private function addListeners():void {
		_container.addEventListener(MouseEvent.MOUSE_DOWN, onTankMouseDown);
		_container.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		_container.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		
		for each (var switchBtn:Sprite in [_tankSwitchLeftBtn, _tankSwitchRightBtn, _weaponSwitchLeftBtn, _weaponSwitchRightBtn]) {
			switchBtn.addEventListener(MouseEvent.MOUSE_OVER, onSwitchBtnMouseOver);
			switchBtn.addEventListener(MouseEvent.MOUSE_OUT, onSwitchBtnMouseOut);
			switchBtn.addEventListener(MouseEvent.CLICK, onSwitchBtnClick);
		}
	}
	
	private function removeListeners():void {
		_container.removeEventListener(MouseEvent.MOUSE_DOWN, onTankMouseDown);
		_container.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		_container.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		for each (var switchBtn:Sprite in [_tankSwitchLeftBtn, _tankSwitchRightBtn, _weaponSwitchLeftBtn, _weaponSwitchRightBtn]) {
			switchBtn.removeEventListener(MouseEvent.MOUSE_OVER, onSwitchBtnMouseOver);
			switchBtn.removeEventListener(MouseEvent.MOUSE_OUT, onSwitchBtnMouseOut);
			switchBtn.removeEventListener(MouseEvent.CLICK, onSwitchBtnClick);
		}
	}

	private function stopSwitching():void {

	}

	private function createPlayBtn():void {
		_playBtn = new NewGameBtn();
		_playBtn.buttonMode = true;
		_playBtn.x = 300;
		_playBtn.y = 350;
		_playBtn.gotoAndStop(1);
		/*_playBtn.graphics.beginFill(0xafafaf, .5);
		_playBtn.graphics.drawRect(-20, -20, 40, 40);
		_playBtnTxt = new TextField();
		_playBtnTxt.x = -10;
		_playBtnTxt.y = -10;
		_playBtnTxt.text = "play";
		_playBtnTxt.selectable = false;
		_playBtnTxt.autoSize = TextFieldAutoSize.LEFT;
		_playBtnTxt.mouseEnabled = false;
		_playBtn.addChild(_playBtnTxt);*/
		_playBtn.addEventListener(MouseEvent.MOUSE_OVER, onPlayBtnMouseOver);
		_playBtn.addEventListener(MouseEvent.MOUSE_OUT, onPlayBtnMouseOut);
		_playBtn.addEventListener(MouseEvent.CLICK, onPlayBtnClick);
		
	}

	private function createTankSwitchBtns():void {
		_tankSwitchLeftBtn = new SwitchBtn();
		_tankSwitchRightBtn = new SwitchBtn();
		_tankSwitchRightBtn.rotation = 180;
		for each (var switchBtn:SwitchBtn in [_tankSwitchLeftBtn, _tankSwitchRightBtn]) {
			/*switchBtn.graphics.beginFill(0x123f56);
			switchBtn.graphics.drawRect(-10, -30, 20, 60);
			switchBtn.graphics.endFill();*/
			
			switchBtn.y = _tank.originY;
		}
		_tankSwitchLeftBtn.x = _tank.originX - 100;
		_tankSwitchRightBtn.x = _tank.originX + 100;
	}

	private function createWeapon():void {
		_weapon = new TankGun();
		_weapon.y = _tank.originY + 100;
		_weapon.x = _tank.originX;
	}

	private function createWeaponSwitchBtns():void {
		_weaponSwitchLeftBtn = new SwitchBtn();
		_weaponSwitchRightBtn = new SwitchBtn();
		_weaponSwitchRightBtn.rotation = 180;
		for each (var switchBtn:SwitchBtn in [_weaponSwitchLeftBtn, _weaponSwitchRightBtn]) {
			/*switchBtn.graphics.beginFill(0x1a3fa6);
			switchBtn.graphics.drawRect(-10, -30, 20, 60);
			switchBtn.graphics.endFill();*/
			switchBtn.y = _weapon.y;
		}
		_weaponSwitchLeftBtn.x = _weapon.x - 100;
		_weaponSwitchRightBtn.x = _weapon.x + 100;
	}

	private function onPlayBtnMouseOver(event:MouseEvent):void {
		if (_playBtn.hasEventListener(Event.ENTER_FRAME)) {
			_playBtn.removeEventListener(Event.ENTER_FRAME, animationNext);
			_playBtn.removeEventListener(Event.ENTER_FRAME, animationPrev);
		}
		_playBtn.addEventListener(Event.ENTER_FRAME, animationNext);
		//TweenMax.to(_playBtn, .4, {glowFilter:{color:0x91e600, alpha:1, blurX:10, strength : 4, blurY:10}});
	}
	private function onPlayBtnMouseOut(event:MouseEvent):void {
		if (_playBtn.hasEventListener(Event.ENTER_FRAME)) {
			_playBtn.removeEventListener(Event.ENTER_FRAME, animationNext);
			_playBtn.removeEventListener(Event.ENTER_FRAME, animationPrev);
		}
		_playBtn.addEventListener(Event.ENTER_FRAME, animationPrev);
		//TweenMax.to(_playBtn, .4, {glowFilter:{color:0x91e600, alpha:0, strength : 10, blurX:300, blurY:300}});
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

	private function onSwitchBtnClick(event:MouseEvent):void {
		if (event.target == _tankSwitchLeftBtn || event.target == _tankSwitchRightBtn) {
			switchTanks(event.target == _tankSwitchLeftBtn ? -1 : 1);
		} else {
			switchWeapons(event.target == _weaponSwitchLeftBtn ? -1 : 1);
		}
	}

	private function onSwitchBtnMouseOver(event:MouseEvent):void {
		//event.target["alpha"] = .4;
		TweenMax.to(event.target, .4, {glowFilter:{color:0xb5b5b5, alpha:1, blurX:10, strength : 4, blurY:10}});
	}

	private function onSwitchBtnMouseOut(event:MouseEvent):void {
		//event.target["alpha"] = 1;
		TweenMax.to(event.target, 4, {glowFilter:{color:0xb5b5b5, alpha:0, strength : 10, blurX:300, blurY:300}});
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
			if (_dragBackTankTween) { _dragBackTankTween.kill(); }
		} else if (_weapon.hitTestPoint(event.stageX, event.stageY)) {
			_dragWeapon = true;
			if (_dragBackWeaponTween) { _dragBackWeaponTween.kill(); }
		}
	}
	private function onMouseUp(event:MouseEvent):void {
		_dragTank = false;
		_dragWeapon = false;
		if (Math.abs(_tank.x - _defaultTankPoint.x) < .6) {
			if (_tank.x != _defaultTankPoint.x) {
				_dragBackTankTween = new TweenMax(_tank, .4, {x : _defaultTankPoint.x});
			}
		} else {
			switchTanks();
		}
		if (Math.abs(_weapon.x - _defaultWeaponPoint.x) < 20) {
			if (_weapon.x != _defaultWeaponPoint.x) {
				_dragBackWeaponTween = new TweenMax(_weapon, .4, {x : _defaultWeaponPoint.x});
			}
		} else {
			switchWeapons();
		}
	}

	private function switchTanks(direction:uint = 0):void {
		var coef:int;
		if (direction != 0) { coef = direction; } else {
			coef = _tank.x > _defaultTankPoint.x ? 1 : -1;
		}
		TweenMax.killTweensOf(_tank.gun);
		TweenMax.killTweensOf(_tank.tankBase);
		TweenMax.to(_tank,  .3, {originX : _tank.originX + coef * 60, scaleX : 4, scaleY : .1, blurFilter:{blurX:20},
															alpha : 0, ease:Linear.easeOut, onComplete : onTankShiftComplete});
	}

	private function onTankShiftComplete():void {
		if (_closed) { return; }
		if (_container.contains(_tank)) { _container.removeChild(_tank); }
		const vo:TankVO = new TankVO();
		const point:Point = new Point(_tank.x,  _tank.y);
		vo.tankBase = _tank.vo.tankBase == 0 ? 1 : 0;
		vo.weaponType = _weapon.type;
		vo.ability = 1;
		_tank = Tank.createPlayerTank(vo);
		_tank.liveTab.visible = false;
		_tank.liveTabBckg.visible = false;
		const distance:Number = Math.abs(_defaultTankPoint.x -point.x);
		_tank.x = point.x < _defaultTankPoint.x ? point.x + 2*distance :point.x - 2 * distance;
		_tank.alpha = 0;
		_tank.filters = [new BlurFilter(20)];
		_tank.scaleX = 4;
		_tank.scaleY = .1; _tank.y = point.y;
		_container.addChild(_tank);
		TweenMax.to(_tank,  .3, {x : _defaultTankPoint.x, scaleX : 1, scaleY : 1, alpha : 1, ease:Linear.easeIn,
															blurFilter:{blurX:0}, onComplete : function():void { _tank.filters = []; }});
	}

	private function switchWeapons(direction:uint = 0):void {
		var coef:int;
		if (direction != 0) { coef = direction; } else {
			coef = _weapon.x > _defaultWeaponPoint.x ? 1 : -1;
		}
		TweenMax.killTweensOf(_weapon);
		TweenMax.to(_weapon,  .3, {x : _weapon.x + coef * 60, scaleX : 4, scaleY : .1, blurFilter:{blurX:20},
															alpha : 0, ease:Linear.easeOut, onComplete : onWeaponShiftComplete});
	}

	private function onWeaponShiftComplete():void {
		if (_closed) { return; }
		if (_container.contains(_weapon)) { _container.removeChild(_weapon); }
		const point:Point = new Point(_weapon.x,  _weapon.y);
		var weaponType:uint;
		if (_weapon.type == TankGun.ROCKET) { weaponType = TankGun.MINIGUN;
		} else if (_weapon.type == TankGun.MINIGUN) { weaponType = TankGun.TAIL_ROCKET;
		} else { weaponType = TankGun.ROCKET; }
		_weapon = new TankGun(weaponType);
		const distance:Number = Math.abs(_defaultWeaponPoint.x -point.x);
		_weapon.x = point.x < _defaultWeaponPoint.x ? point.x + 2*distance :point.x - 2 * distance;
		_weapon.alpha = 0;
		_weapon.filters = [new BlurFilter(20)];
		_weapon.scaleX = 4;
		_weapon.scaleY = .1; _weapon.y = point.y;
		_container.addChild(_weapon);
		_tank.removeGun();
		_tank.updateGun(weaponType);
		TweenMax.to(_weapon,  .3, {x : _defaultWeaponPoint.x, scaleX : 1, scaleY : 1, alpha : 1, ease:Linear.easeIn,
															blurFilter:{blurX:0}, onComplete : function():void { _weapon.filters = []; }});
	}

	private function onMouseMove(event:MouseEvent):void {
		if (_dragTank) {
			_tank.originX = event.stageX;
		} else
		if (_dragWeapon) {
			_weapon.x = event.stageX;
		}
	}

	private function switchScene():void {
		dispatchEvent(new SceneEvent(SceneEvent.WANT_REMOVE));
	}

}
}
