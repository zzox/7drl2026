package game.scenes;

import core.gameobjects.Sprite;
import core.scene.Scene;
import kha.Assets;

var sets:Array<Array<Int>> = [
    [0x403353, 0x793080, 0xbc409b],
    [0x143464, 0x285cc4, 0x20d6c7],
    [0x333941, 0x4a5462, 0x6d758d],
];

var mods:Array<Array<Int>> = [
    [2, 3, 7],
    [3, 4, 9],
    [5, 7, 13],
];

class BgScene extends Scene {
    public static var rand:kha.math.Random;
    var items:Array<BgItem> = [];
    var onSet:Int = 2;

    public function new () {
        super();
        rand = new kha.math.Random(1312);
    }

    override function create () {
        for (_ in 0...64) {
            final bgItem = new BgItem();
            items.push(bgItem);
            entities.push(bgItem);
            bgItem.color = 0x000000;
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

    public function set (index:Int) {
        final fromMods = mods[onSet];
        final fromSets = sets[onSet];

        final toMods = mods[index];
        final toSets = sets[index];
        for (i in 0...items.length) {
            if (i % toMods[0] == 0) {
                timers.addTimer(3.0, () -> {
                    items[i].color = toSets[0];
                });
            } else if (i % toMods[1] == 0) {
                timers.addTimer(1.0, () -> {
                    items[i].color = toSets[0];
                });
                timers.addTimer(2.0, () -> {
                    items[i].color = toSets[1];
                });
            } else if (i % toMods[2] == 0) {
                timers.addTimer(1.0, () -> {
                    items[i].color = toSets[0];
                });
                timers.addTimer(2.0, () -> {
                    items[i].color = toSets[1];
                });
                timers.addTimer(3.0, () -> {
                    items[i].color = toSets[2];
                });
            }
        }

        trace('setting', index);
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
