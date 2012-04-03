package {
import com.flashdynamix.utils.SWFProfiler;
import flash.system.Security;

import flash.display.MovieClip;

import flash.display.Sprite;

import game.GameController;
import game.SceneController;

import mochi.as3.MochiAd;
import mochi.as3.MochiServices;

import sound.Sounds;

import sound.SoundsManager;

[SWF(width=600, height=600, frameRate=25)]
	public class Main extends Sprite {
		private var container:Sprite;
		var _mochiads_game_id:String = "88119fe352061898";

		public static var MOCHI_ON:Boolean = false;

		public function Main() {
			Security.allowInsecureDomain("*");
			Security.allowDomain("*");
			Security.allowDomain("http://www.mochiads.com/static/lib/services/");
			
			start();
		}

		private function start():void {
			container = new Sprite();
			//MochiServices.connect( _mochiads_game_id, root, onMochiConnectError);
			//container.alpha = .04;
			addChild(container);

			new SceneController(container);
			//SWFProfiler.init(stage, container);
		}

		private function onMochiConnectError():void {
			MOCHI_ON = false;
			trace("Mochi connect fails");
		}

	}
}