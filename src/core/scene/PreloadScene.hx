package core.scene;

import core.Types;
import core.gameobjects.Sprite;
import kha.Assets;
import kha.Image;
import kha.graphics2.Graphics;

class PreloadScene extends Scene {
    var barWidth:Int;
    var barPos:IntVec2;
    var progressRect:Sprite;
    var pro:Float = 0;

    override function create () {
        barWidth = Std.int(camera.width / 2);
        barPos = new IntVec2(Std.int(barWidth / 2), Std.int(camera.height * 3 / 4));

        final imageAsset:Image = Assets.images.made_with_kha;

        makeSprite(camera.width / 2 - imageAsset.width / 2, camera.height / 4, imageAsset);
    }

    override function render (graphics:Graphics, clears:Bool) {
        super.render(graphics, clears);

        graphics.begin(false);
        graphics.color = 0xffa4aaac;
        graphics.fillRect(barPos.x, barPos.y, barWidth, 1);
        graphics.color = 0xffffffff;
        graphics.fillRect(barPos.x, barPos.y, Std.int(Assets.progress * barWidth), 1);
        graphics.end();
    }
}
