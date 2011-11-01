/**
 * User: dima
 * Date: 1/11/11
 * Time: 5:05 PM
 */
package game.tank {
public class TankDestroyMethod {
    private var _tank:Tank;

    public function TankDestroyMethod(tank:Tank):void {
        _tank = tank;
    }

    public function get tank():Tank { return _tank; }

    public function destroy():void {}
}
}
