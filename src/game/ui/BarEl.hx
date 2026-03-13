package game.ui;

import game.scenes.BattleScene;
import kha.Assets;

typedef BarColor = {
    var min:Float; // 0-1
    var index:Int;
}

typedef PulseWindows = Array<Array<Float>>;

class BarEl extends UiElement {
    public var value:Int;
    var max:Int;
    var colors:Array<BarColor>;
    var fullWidth:Int;
    var pulseWindows:Null<PulseWindows>;

    public function new (x:Float, y:Float, sizeX:Int, sizeY:Int,
        topLeftX:Int, topLeftY:Int, bottomRightX:Int, bottomRightY:Int,
        elementSizeX:Int, elementSizeY:Int,
        colors:Array<BarColor>, value:Int, max:Int, ?pulseWindows:PulseWindows
    ) {
        super(x, y, sizeX, sizeY, topLeftX, topLeftY, bottomRightX, bottomRightY, elementSizeX, elementSizeY, colors[0].index, Assets.images.ui);

        this.fullWidth = elementSizeX;
        this.colors = colors;
        this.value = value;
        this.max = max;
        this.pulseWindows = pulseWindows;
    }

    override function update (delta:Float) {
        final ratio = value / max;
        for (c in colors) {
            if (ratio >= c.min) {
                tileIndex = c.index;
            }
        }

        elementSizeX = Std.int(Math.max(2, Math.floor(Math.min(ratio, 1) * fullWidth)));

        visible = value > 0;

        if (pulseWindows != null) {
            if (ratio > pulseWindows[0][0] && ratio < pulseWindows[0][1]) {
                visible = visible && BattleScene.pulseOn;
            } else if (ratio > pulseWindows[1][0] && ratio < pulseWindows[1][1]) {
                visible = visible && BattleScene.shortPulseOn;
            }
        }

        super.update(delta);
    }
}
