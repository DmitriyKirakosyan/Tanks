package {
import flash.display.Sprite;

import game.GameController;
import game.SceneController;

[SWF(width=600, height=600, frameRate=25)]
	public class Main extends Sprite {
		private var container:Sprite; 

		public function Main() {
			container = new Sprite(); 
			this.addChild(container);

			new SceneController(container);
		}

	}
}