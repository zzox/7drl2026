package game.scenes;

import core.util.Util;
import game.ui.GeneSelectWindow;
import game.ui.GenesDisplay;
import game.ui.UiText;
import game.world.Run;

class MixScene extends ButtonScene {
    override function create () {
        super.create();

        entities.push(makeBitmapText(32, 32, 'Mixing up ${Run.inst.mix.guy.name}'));

        final guy = new GuyIcon(152, 48);
        guy.dna = Run.inst.mix.guy;

        final roomCopy = Run.inst.mix.prev;
        final gd = new GenesDisplay(64, 72, roomCopy, 24);

        entities.push(guy);
        entities.push(gd);

        buttons.push(makeUiTextButton(140, 100, 40, 16, 16, 'NEXT', () -> {
            launchNextScene();
        }));

        for (i in 0...8) {
            if (i == 7) {
                timers.addTimer(0.5 + i * 0.3 + i * 0.15, () -> {
                    gd.genes = Run.inst.mix.value;
                    // WARN:
                    guy.dna.body = Run.inst.placeRand.GetUpTo(7);
                });
            } else {
                timers.addTimer(0.5 + i * 0.3 + i * 0.15, () -> {
                    shuffle(gd.genes, Run.inst.placeRand);
                    guy.dna.body = Run.inst.placeRand.GetUpTo(7);
                });
            }
        }
    }

    function launchNextScene () {
        Run.inst.handleMix();
        game.changeScene(new RosterScene());
    }
}
