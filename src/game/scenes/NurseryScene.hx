package game.scenes;

import core.Game;
import core.gameobjects.BitmapText;
import game.ui.GeneSelectWindow.GuyIcon;
import game.ui.GeneSyncDisplay;
import game.ui.GenesDisplay;
import game.ui.UiElement;
import game.ui.UiText;
import game.util.Player;
import game.world.Dna.mutItems;
import game.world.Run;
import kha.Assets;

class NurseryScene extends ButtonScene {
    var p1:GuyIcon;
    var p2:GuyIcon;

    var name1:BitmapText;
    var name2:BitmapText;

    var resultText:BitmapText;
    var displayItems:Array<{ icon:GuyIcon, gd:GenesDisplay, name:BitmapText }> = [];

    override function create () {
        super.create();

        final p1 = new GuyIcon(16, 16);
        final p2 = new GuyIcon(16, 40);

        p1.dna = Run.inst.nursery.parents[0];
        p2.dna = Run.inst.nursery.parents[1];

        final g1 = new GeneSyncDisplay(32, 24, p1.dna.genes, true, Run.inst.nursery.children.length);
        final g2 = new GeneSyncDisplay(32, 48, p2.dna.genes, false, Run.inst.nursery.children.length);

        entities.push(p1);
        entities.push(g1);
        entities.push(p2);
        entities.push(g2);

        entities.push(name1 = makeBitmapText(32, 12, p1.dna.name));
        entities.push(name2 = makeBitmapText(32, 36, p2.dna.name));

        resultText = makeBitmapText(32, 36, '${p1.dna.name} and ${p2.dna.name} had ${Run.inst.nursery.children.length} son${Run.inst.nursery.children.length == 1 ? '' : 's'}');
        resultText.setPosition(160 - Math.floor(resultText.textWidth / 2), 16);
        resultText.visible = false;
        entities.push(resultText);

        displayItems = [];
        for (i in 0...Run.inst.nursery.children.length) {
            final child = Run.inst.nursery.children[i];

            final icon = new GuyIcon(16, 80 + i * 24);
            icon.dna = child;

            final gd = new GenesDisplay(32, 80 + i * 24 + 8, [], 24);

            final name = makeBitmapText(32, 80 + i * 24 - 4, child.name);

            entities.push(icon);
            entities.push(gd);
            entities.push(name);

            icon.visible = false;
            name.visible = false;

            displayItems.push({ icon: icon, gd: gd, name: name });
        }

        for (i in 0...Run.inst.nursery.children.length) {
            final child = Run.inst.nursery.children[i];

            timers.addTimer(i * 1.0 + FirstBounce + 0.5, () -> {
                displayItems[i].icon.visible = true;

                for (j in 0...child.genes.length) {
                    timers.addTimer(j * IncTime, () -> {
                        displayItems[i].gd.genes = child.genes.slice(0, j);

                        if (j >= 0 && mutItems.contains(child.genes[j - 1])) {
                            Player.playSound(Assets.sounds.sons_fx2, 0.05);
                            timers.addTimer(0.1, () -> {
                                Player.playSound(Assets.sounds.sons_fx1, 0.05);
                            });
                        } else if (j > 0 && child.genes[j - 1] != None) {
                            Player.playSound(Assets.sounds.sons_noise3, 0.05);
                        }

                        if (j == child.genes.length - 1) {
                            displayItems[i].name.visible = true;
                            displayItems[i].icon.visible = true;
                            if (i == Run.inst.nursery.children.length - 1) {
                                resultText.visible = true;
                                p1.visible = false;
                                p2.visible = false;
                                name1.visible = false;
                                name2.visible = false;

                                final nextButton = makeUiTextButton(140, 32, 40, 16, 16, 'NEXT', () -> {
                                    Run.inst.handleNursery();
                                    game.changeScene(new SyncScene());
                                });
                                buttons.push(nextButton);
                            }
                        }
                    });
                }
            });
        }
    }
}
