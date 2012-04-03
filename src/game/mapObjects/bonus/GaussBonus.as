/**
 * Created by : Dmitry
 * Date: 4/3/12
 * Time: 7:13 AM
 */
package game.mapObjects.bonus {
public class GaussBonus extends GameBonus {
	private var _view:GaussGunBonusView;
	public function GaussBonus() {
		super(GameBonus.GAUSS_GUN);
		_view = new GaussGunBonusView();
		_view.scaleX = _view.scaleY = 1.5;
		_view.x = -_view.width / 2;
		_view.y = -_view.height / 2;
		addChild(_view);
	}
}
}
