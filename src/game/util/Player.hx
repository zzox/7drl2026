package game.util;

import kha.Assets;
import kha.audio1.AudioChannel;

class Player {
    public static var sfx:Bool = true;
    public static var music:Bool = true;

    public static function playSound (sound:kha.Sound, volume:Float) {
        if (sfx) {
            core.system.Sound.play(sound, volume, false);
        }
    }

    public static function playCry () {
        final cry = [Assets.sounds.sons_fx_cry1, Assets.sounds.sons_fx_cry2, Assets.sounds.sons_fx_cry3][Math.floor(Math.random() * 3)];
        playSound(cry, 0.2);
    }

    public static function playMusic (sound:kha.Sound, volume:Float):Null<AudioChannel> {
        // if (music) {
        return core.system.Sound.play(sound, volume, false);
        // }
    }
}
