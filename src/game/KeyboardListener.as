/**
 * User: dima
 * Date: 29/12/11
 * Time: 10:23 AM
 */
package game {
import flash.display.Sprite;
import flash.events.EventDispatcher;
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;

public class KeyboardListener extends EventDispatcher{
	private var _container:Sprite;
	private var _keyPressed:uint;

	public static const LEFT:uint = 1;
	public static const RIGHT:uint = 2;
	public static const UP:uint = 3;
	public static const DOWN:uint = 4;
	public static const NOTHING:uint = 0;

	public function KeyboardListener(container:Sprite) {
		_container = container;
	}

	public function get keyPressed():uint { return _keyPressed; }

	public function addListeners():void {
		_container.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		_container.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
	}
	public function removeListeners():void {
		_container.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		_container.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
	}

	private function onKeyDown(event:KeyboardEvent):void {
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
		_keyPressed = NOTHING;
	}

}
}
