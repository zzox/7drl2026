package game.ui;

import core.system.Camera;
import core.util.Util;
import game.ui.UiText;
import game.ui.UiWindow.NumColumn;
import game.world.World;
import kha.graphics2.Graphics;

class StatsWindow extends UiWindow {
    var world:World;

    var stats:NumColumn;
    var empStats:NumColumn;

    public function new (x:Int, y:Int, world:World) {
        super(x, y, 'Stats');

        makeTopBottom(100, 240);
        makeXButton();
        stats = makeNumColumn(4, 20, 92, ['Temp', 'Percent']);
        addUpChild(4, 70, makeBlackText('Employees'));
        empStats = makeNumColumn(4, 80, 92, ['One', 'Two', 'Three', 'Four']);
        
        this.world = world;
    }

    override function update (delta:Float) {
        final percentage = nanZeroDiv(1, Math.floor(Math.random() * 10));
        setNumColumnString(stats, 'Temp', '${Math.round(0.6789 * 10000) / 100}%');
        setNumColumnString(stats, 'Percent', '${percentage}%');

        setNumColumn(empStats, 'One', 111);
        setNumColumn(empStats, 'Two', 2222);
        setNumColumn(empStats, 'Three', 33);
        setNumColumn(empStats, 'Four', 4);
    }

    override function render(g2:Graphics, cam:Camera) {
        super.render(g2, cam);
        renderNumColumn(stats, x, y, g2, cam);
        renderNumColumn(empStats, x, y, g2, cam);
    }
}
