/**
 * Created by : Dmitry
 * Date: 4/3/12
 * Time: 7:13 AM
 */
package game.mapObjects.bonus {
public class GaussBonus extends GameBonus {
	public function GaussBonus() {
		super(GameBonus.GAUSS_GUN);
		addChild(new GaussGunBonusView());
	}
}
}
