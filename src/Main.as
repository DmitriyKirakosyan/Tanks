package {
import com.flashdynamix.utils.SWFProfiler;

import flash.display.MovieClip;

import flash.display.Sprite;

import game.GameController;
import game.SceneController;

import mochi.as3.MochiAd;
import mochi.as3.MochiServices;

[SWF(width=600, height=600, frameRate=25)]
	public class Main extends Sprite {
		private var container:Sprite;
		//mochimedia.com
		var _mochiads_game_id:String = "88119fe352061898";

		public function Main() {
			start();
			/*
			MochiAd.showPreGameAd( {
					skip: true,
					id: _mochiads_game_id,              // This is the game ID for displaying ads!
					clip: this,             // We are displaying in a container (which is dynamic)
					ad_finished: start      // Ad has completed
			} );
			*/
		}

		private function start():void {
			//MochiServices.connect( _mochiads_game_id, stage);
			container = new Sprite();
			this.addChild(container);

			new SceneController(container);
			SWFProfiler.init(stage, container);
		}

	}
}