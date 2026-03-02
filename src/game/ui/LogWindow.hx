package game.ui;

import core.system.Camera;
import game.data.Logs;
import game.scenes.UiScene;
import game.ui.UiText;
import game.world.WorldEvent;
import kha.Assets;
import kha.graphics2.Graphics;

function getLogColor (type:EventType) {
    return switch (type) {
        case Arrive: UiScene.Red;
        case Leave: UiScene.Green;
    }
}

class LogWindow extends UiWindow {
    var logs:Array<LogData>;

    public function new (x:Int, y:Int, logs:Logs) {
        super(x, y, 'Logs');

        makeTopBottom(320, 246);
        makeXButton();
        addChild(4, UiWindow.TopHeight + 20, new UiElement(0, 0, 16, 16, 3, 3, 13, 13, 320 - 8, 246 - UiWindow.TopHeight - 20 - 4, 5, Assets.images.ui));

        this.logs = logs.items;
    }

    override function render (g2:Graphics, cam:Camera) {
        super.render(g2, cam);

        final textItem = makeWhiteText('');

        final renderLogs = logs.filter(l -> true).slice(-20);
        renderLogs.reverse();
        for (l in 0...renderLogs.length) {
            final yPos = y + 246 - l * 10 - 18;
            textItem.color = getLogColor(renderLogs[l].type);
            textItem.setPosition(x + 6, yPos);
            textItem.setText(formatLog(renderLogs[l]));
            textItem.render(g2, cam);
            textItem.setText('Day ${renderLogs[l].day + 1}, ${renderLogs[l].time}');
            textItem.setPosition(x + 320 - textItem.textWidth - 8, yPos);
            textItem.color = UiScene.LightGrey;
            textItem.render(g2, cam);
        }
    }
}

inline function formatLog (data:LogData):String {
    return switch (data.type) {
        case Arrive: '${data.name} arrived';
        case Leave: '${data.name} left';
    }
}
