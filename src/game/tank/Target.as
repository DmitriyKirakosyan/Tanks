package game.tank {
	import flash.display.Sprite;
	import flash.geom.ColorTransform;

	public class Target extends Sprite {
		
		public function Target() {
			var view:Tank = new Tank;
			var _colorInfo:ColorTransform = new ColorTransform;
			_colorInfo.color = Math.random() * 0xffffff;
			view.transform.colorTransform = _colorInfo;
			addChild(view);
		}
	}
}