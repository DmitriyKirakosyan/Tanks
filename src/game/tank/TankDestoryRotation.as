/**
 * Created by IntelliJ IDEA.
 * User: dima
 * Date: 1/11/11
 * Time: 5:11 PM
 * To change this template use File | Settings | File Templates.
 */
package game.tank {
import com.greensock.TimelineMax;
import com.greensock.TweenMax;

public class TankDestoryRotation extends TankDestroyMethod{

    private var _bamTimeline:TimelineMax;

    public function TankDestoryRotation(tank:Tank) {
        super(tank);
    }

    override public function destroy():void {
        _bamTimeline = new TimelineMax({onComplete : onBamComplete});
        _bamTimeline.insert(
            new TweenMax(tank.tankBase, 2, {x : tank.tankBase.x + Math.random()*80-40,
                                                                y : tank.tankBase.y + Math.random()*80-40,
                                                                rotation : tank.tankBase.rotation + Math.random()*100})
        );
        _bamTimeline.insert(
            new TweenMax(tank.gun, 1.5, {x : tank.gun.x + Math.random()*400-200,
                                                            y : tank.tankBase.y + Math.random()*400-200,
                                                            rotation : tank.tankBase.rotation + Math.random()*300})
        );
        _bamTimeline.append(
            new TweenMax(this, 1.5, {alpha : 0})
        );
    }

    private function onBamComplete():void {
        tank.removeChild(tank.gun);
        tank.removeChild(tank.tankBase);
        tank.gun.x = 0; tank.gun.y = 0;
        tank.alpha = 1;
        tank.gun.rotation = 0;
        tank.tankBase.rotation = 0;
    }

}
}
