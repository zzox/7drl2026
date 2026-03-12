package game.scenes;

import core.Game;
import core.gameobjects.AnimSprite;
import core.gameobjects.Sprite;
import core.scene.Scene;
import game.util.Player;
import kha.Assets;
import kha.Sound;
import kha.audio1.AudioChannel;
import kha.input.KeyCode;

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
    static inline final MusicVolume:Float = 0.05;
    public static var rand:kha.math.Random;
    var items:Array<BgItem> = [];
    var onSet:Int = 2;
    var notes:Array<Sound>;
    var playingNotes:Array<AudioChannel> = [];

    public function new () {
        super();
        rand = new kha.math.Random(1312);

        notes = [
            Assets.sounds.sons_note1,
            Assets.sounds.sons_note2,
            Assets.sounds.sons_note3,
            Assets.sounds.sons_note4,
            Assets.sounds.sons_note5,
            Assets.sounds.sons_note7,
            Assets.sounds.sons_note8,
            Assets.sounds.sons_note9
        ];

        timers.addTimer(4.0, () -> { playNote(0); });
        timers.addTimer(8.0, () -> { playNote(1); });
        timers.addTimer(10.0, () -> { playNote(2); });
        timers.addTimer(6.0, () -> { playNote(3); });
        timers.addTimer(12.0, () -> { playNote(4); });
        timers.addTimer(16.0, () -> { playNote(5); });
        timers.addTimer(16.0, () -> { playNote(6); });
        timers.addTimer(16.0, () -> { playNote(7); });
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
        playingNotes = playingNotes.filter(n -> !n.finished);

        if (Game.keys.justPressed(KeyCode.B)) {
            if (invisible) {
                show();
            } else {
                clear();
            }
        }

        if (Game.keys.justPressed(KeyCode.N)) {
            Player.sfx = !Player.sfx;
            if (Player.sfx) {
                Player.playSound(Assets.sounds.sons_fx1, 0.1);
            } else {
                Player.playSound(Assets.sounds.sons_fx2, 0.1);
            }
        }

        if (Game.keys.justPressed(KeyCode.M)) {
            Player.music = !Player.music;
            muteMusic();
        }

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
            } else {
                items[i].color = 0x000000;
            }
        }

        // trace('setting', index);
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

    final phases = [
        8.0,
        8.2,
        8.7,
        10.0,
        11.0,
        13.0,
        14.0,
        18.0,
    ];

    function playNote (num:Int) {
        timers.addTimer(phases[num], () -> {
            final note = Player.playMusic(notes[num], MusicVolume * (Player.music ? 1.0 : 0.0));
            if (note != null) {
                playingNotes.push(note);
            }
            playNote(num);
        });
    }

    function muteMusic () {
        for (n in playingNotes) {
            n.volume = MusicVolume * (Player.music ? 1.0 : 0.0);
        }
    }
}

class BgItem extends AnimSprite {
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

        final sizeRand = BgScene.rand.GetFloat();

        final frames = if (sizeRand > 0.9) {
            [63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 62, 61, 62, 61, 62, 61, 60, 59, 60, 59, 62, 61];
        } else if (sizeRand > 0.8) {
            [63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 62, 61, 62, 61];
        } else {
            [63];
        }

        super(x, y, Assets.images.ui, 8, 8, 10 + BgScene.rand.GetUpTo(5), frames, true);
        tileIndex = 63;
    }
}
