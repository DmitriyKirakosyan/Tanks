package game {
import flash.display.Sprite;

import game.events.SceneEvent;

import menu.TankPodium;

public class SceneController {
	private var _gameScene:GameController;
	private var _menuScene:TankPodium;

	public function SceneController(container:Sprite) {
		_gameScene = new GameController(container);
		_menuScene = new TankPodium(container);

		_gameScene.open();

		addListeners();
	}

	private function addListeners():void {
		_gameScene.addEventListener(SceneEvent.WANT_REMOVE, onGameSceneWantRemove);
		_menuScene.addEventListener(SceneEvent.WANT_REMOVE, onMenuSceneWantRemove);
	}

	private function onGameSceneWantRemove(event:SceneEvent):void {
		_gameScene.remove();
		_menuScene.open();
	}

	private function onMenuSceneWantRemove(event:SceneEvent):void {
		_menuScene.remove();
		_gameScene.open();
	}
}
}
