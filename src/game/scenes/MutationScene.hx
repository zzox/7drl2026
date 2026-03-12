package game.scenes;

import core.Game;
import core.util.Util;
import game.ui.GeneSelectWindow;
import game.ui.GenesDisplay;
import game.ui.UiText;
import game.util.Player;
import game.world.Dna.mutItems;
import game.world.Run;
import kha.Assets;

class MutationScene extends ButtonScene {
    var gd:GenesDisplay;

    override function create () {
        super.create();

        final text = makeBitmapText(0, 32, 'Mutating ${Run.inst.mutation.guy.name}');
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
                    Player.playSound(Assets.sounds.sons_fx_bonus2, 0.1);
                });
            } else {
                timers.addTimer(0.5 + i * 0.15 + i * 0.08, () -> {
                    Player.playSound(Assets.sounds.sons_fx_bonus3, 0.07);
                    gd.dIndex = Run.inst.placeRand.GetUpTo(23);
                });
            }
        }

        Game.bgScene.set(0);
    }

    function startShuffle () {
        for (i in 0...8) {
            if (i == 7) {
                timers.addTimer(0.5 + i * 0.15 + i * 0.08, () -> {
                    gd.genes[Run.inst.mutation.index] = Run.inst.mutation.gene;
                    Player.playSound(Assets.sounds.sons_fx_bonus2, 0.1);
                    entities.push(makeBitmapText(140, 104, 'Rad: ${Run.inst.mutation.guy.rad + 3}'));
                    entities.push(makeBitmapText(180, 104, '+3', 0xb4202a));
                });
            } else {
                timers.addTimer(0.5 + i * 0.15 + i * 0.08, () -> {
                    // ATTN: Math.random here. it's fine
                    Player.playSound(Assets.sounds.sons_fx_bonus3, 0.07);
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
