/**
 * User: dima
 * Date: 29/12/11
 * Time: 10:23 AM
 */
package game {
import flash.display.Sprite;
import flash.events.EventDispatcher;
import flash.events.KeyboardEvent;
import flash.events.TextEvent;
import flash.text.engine.TextElement;
import flash.ui.Keyboard;

public class KeyboardListener extends EventDispatcher{
	private var _container:Sprite;
	private var _keyPressed:uint;
	private var _keyCodeStack:Vector.<uint>;

	public static const LEFT:uint = 1;
	public static const RIGHT:uint = 2;
	public static const UP:uint = 3;
	public static const DOWN:uint = 4;
	public static const NOTHING:uint = 0;

	public function KeyboardListener(container:Sprite) {
		_container = container;
		_keyCodeStack = new Vector.<uint>();
	}

	public function get keyPressed():uint { return _keyPressed; }

	public function addListeners():void {
		_container.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		_container.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		_container.addEventListener(TextEvent.TEXT_INPUT, onTextInput);
	}
	public function removeListeners():void {
		_container.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		_container.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		_container.stage.removeEventListener(TextEvent.TEXT_INPUT, onTextInput);
	}

	private function onTextInput(event:TextEvent):void {
		if (event.text == "ф") { trace("yes"); }
	}

	private function onKeyDown(event:KeyboardEvent):void {
		if (_keyCodeStack.indexOf(event.keyCode) != -1) {
			_keyCodeStack.splice(_keyCodeStack.indexOf(event.keyCode), 1);
		}
		_keyCodeStack.push(event.keyCode);

		var availableKey:Boolean = false;
		if (event.keyCode == Keyboard.LEFT || event.keyCode == Keyboard.A) {
			_keyPressed = LEFT;
			availableKey = true;
		} else if (event.keyCode == Keyboard.RIGHT || event.keyCode == Keyboard.D) {
			_keyPressed = RIGHT;
			availableKey = true;
		} else if (event.keyCode == Keyboard.UP || event.keyCode == Keyboard.W) {
			_keyPressed = UP;
			availableKey = true;
		} else if (event.keyCode == Keyboard.DOWN || event.keyCode == Keyboard.S) {
			_keyPressed = DOWN;
			availableKey = true;
		}
		if (availableKey) {
			dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_DOWN));
		}
	}
	private function onKeyUp(event:KeyboardEvent):void {
		var indexKeyCode:uint = _keyCodeStack.indexOf(event.keyCode);
		if (indexKeyCode != -1) {
			_keyCodeStack.splice(_keyCodeStack.indexOf(event.keyCode), 1);
		}
		if (_keyCodeStack.length == 0) {
			_keyPressed = NOTHING;
		} else { updateKeyPressed(); }
	}

	private function updateKeyPressed():void {
		var keyCode:uint = _keyCodeStack[0];
		if (keyCode == Keyboard.LEFT || keyCode == Keyboard.A) {
			_keyPressed = LEFT;
		} else if (keyCode == Keyboard.RIGHT || keyCode == Keyboard.D) {
			_keyPressed = RIGHT;
		} else if (keyCode == Keyboard.UP || keyCode == Keyboard.W) {
			_keyPressed = UP;
		} else if (keyCode == Keyboard.DOWN || keyCode == Keyboard.S) {
			_keyPressed = DOWN;
		}

	}

}
}
