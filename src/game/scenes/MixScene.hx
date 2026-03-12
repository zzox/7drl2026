package game.scenes;

import core.Game;
import core.util.Util;
import game.ui.GeneSelectWindow;
import game.ui.GenesDisplay;
import game.ui.UiText;
import game.util.Player;
import game.world.Run;
import kha.Assets;

class MixScene extends ButtonScene {
    override function create () {
        super.create();

        final text = makeBitmapText(0, 32, 'Mixing up ${Run.inst.mix.guy.name}');
        text.x = 160 - Math.floor(text.textWidth / 2);
        entities.push(text);

        final guy = new GuyIcon(152, 48);
        guy.dna = Run.inst.mix.guy;

        final roomCopy = Run.inst.mix.prev;
        final gd = new GenesDisplay(64, 72, roomCopy, 24);

        entities.push(guy);
        entities.push(gd);

        buttons.push(makeUiTextButton(140, 120, 40, 16, 16, 'NEXT', () -> {
            launchNextScene();
        }));

        for (i in 0...8) {
            if (i == 7) {
                timers.addTimer(0.5 + i * 0.15 + i * 0.08, () -> {
                    gd.genes = Run.inst.mix.value;
                    // WARN:
                    guy.dna.body = Run.inst.placeRand.GetUpTo(7);
                    Player.playSound(Assets.sounds.sons_fx_bonus2, 0.1);

                    entities.push(makeBitmapText(140, 100, 'Rad: ${Run.inst.mix.guy.rad + 1}'));
                    entities.push(makeBitmapText(180, 100, '+1', 0xb4202a));
                });
            } else {
                timers.addTimer(0.5 + i * 0.15 + i * 0.08, () -> {
                    shuffle(gd.genes, Run.inst.placeRand);
                    // WARN:
                    guy.dna.body = Run.inst.placeRand.GetUpTo(7);
                    Player.playSound(Assets.sounds.sons_fx_bonus3, 0.07);
                });
            }
        }

        Game.bgScene.set(0);
    }

    function launchNextScene () {
        Run.inst.handleMix();
        game.changeScene(new RosterScene());
    }
}
