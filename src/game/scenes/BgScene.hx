package game.scenes;

import core.gameobjects.Sprite;
import core.scene.Scene;
import kha.Assets;
import kha.graphics2.Graphics;

class BgScene extends Scene {
    public static var rand:kha.math.Random;
    var items:Array<BgItem> = [];

    public function new () {
        super();
        rand = new kha.math.Random(1312);
    }

    override function create () {
        for (_ in 0...64) {
            final bgItem = new BgItem();
            items.push(bgItem);
            entities.push(bgItem);
        }
    }

    override function update (delta:Float) {
        super.update(delta);

        for (i in items) {
            i.x += i.speed;
            i.y += i.speed;

            if (i.x >= 360) i.x -= 400;
            if (i.y >= 200) i.y -= 220;
        }
    }

    public var invisible:Bool = false;
    public function clear () {
        invisible = true;
        for (i in items) {
            i.visible = false;
        }
    }

    public function show () {
        invisible = false;
        for (i in items) {
            i.visible = true;
        }
    }
}

class BgItem extends Sprite {
    public var speed:Float;

    public function new () {
        final x = BgScene.rand.GetUpTo(400) - 1 - 40;
        final y = BgScene.rand.GetUpTo(220) - 1 - 20;
        final rand = BgScene.rand.GetUpTo(2);
        if (rand == 0) {
            speed = 0.5;
        } else {
            speed = rand;
        }
        super(x, y, Assets.images.ui, 8, 8);
        tileIndex = 63;
    }
}
