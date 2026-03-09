package game.scenes;

import core.util.Util;
import game.ui.GeneSelectWindow;
import game.ui.GenesDisplay;
import game.ui.UiText;
import game.world.Dna.mutItems;
import game.world.Run;

class MutationScene extends ButtonScene {
    var gd:GenesDisplay;

    override function create () {
        super.create();

        final text = makeBitmapText(0, 32, 'Mixing up ${Run.inst.mutation.guy.name}');
        text.x = 160 - Math.floor(text.textWidth / 2);
        entities.push(text);

        final guy = new GuyIcon(152, 48);
        guy.dna = Run.inst.mutation.guy;

        final roomCopy = Run.inst.mutation.prev;
        gd = new GenesDisplay(64, 72, roomCopy, 24);

        entities.push(guy);
        entities.push(gd);

        buttons.push(makeUiTextButton(140, 120, 40, 16, 16, 'NEXT', () -> {
            launchNextScene();
        }));

        for (i in 0...8) {
            if (i == 7) {
                timers.addTimer(0.5 + i * 0.15 + i * 0.08, () -> {
                    gd.dIndex = Run.inst.mutation.index;
                    startShuffle();
                });
            } else {
                timers.addTimer(0.5 + i * 0.15 + i * 0.08, () -> {
                    gd.dIndex = Run.inst.placeRand.GetUpTo(23);
                });
            }
        }
    }

    function startShuffle () {
        for (i in 0...8) {
            if (i == 7) {
                timers.addTimer(0.5 + i * 0.15 + i * 0.08, () -> {
                    gd.genes[Run.inst.mutation.index] = Run.inst.mutation.gene;
                });
            } else {
                timers.addTimer(0.5 + i * 0.15 + i * 0.08, () -> {
                    // ATTN: Math.random here. it's fine
                    gd.genes[Run.inst.mutation.index] = mutItems[Math.floor(Math.random() * mutItems.length)];
                });
            }
        }
    }

    function launchNextScene () {
        Run.inst.handleMutate();
        game.changeScene(new RosterScene());
    }
}
