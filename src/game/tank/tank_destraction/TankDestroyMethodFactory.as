/**
 * Created by : Dmitry
 * Date: 11/1/11
 * Time: 11:49 PM
 */
package game.tank.tank_destraction {
import game.tank.*;

public class TankDestroyMethodFactory {
	private static var _numMethods:uint = 2;

	public function TankDestroyMethodFactory() {
		super();
	}

	public static function createMethodById(methodId:uint, tank:Tank):TankDestroyMethod {
		var result:TankDestroyMethod;
		switch (methodId) {
			case 0 :
								result = new TankDestoryRotation(tank);
								break;
			default : result = new TankDestroyFlash(tank);
		}
		return result;
	}

	public static function createRandomMethod(tank:Tank):TankDestroyMethod {
		return createMethodById(Math.random()*_numMethods, tank);
	}
}
}
