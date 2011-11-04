package state {
import game.tank.Tank;
import game.tank.TankVO;

public class UserState {
	private static var _instance:UserState;

	private var _tankVO:TankVO;

	public static function get instance():UserState {
		if (!_instance) { _instance = new UserState(); }
		return _instance;
	}

	public function UserState() {
		super();
		_tankVO = new TankVO();
	}

	public function get tankVO():TankVO { return _tankVO; }
	public function set tankVO(value:TankVO):void {
		_tankVO = value;
	}
}
}
