package game.scenes;

import core.gameobjects.AnimSprite;
import core.gameobjects.BitmapText;
import core.gameobjects.Sprite;
import game.ui.GeneSelectWindow.GuyIcon;
import game.ui.GeneSyncDisplay;
import game.ui.GenesDisplay;
import game.ui.UiText;
import game.util.Player;
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
                        displayItems[i].gd.genes = child.genes.slice(0, j + 1);

                        compareItems(i, j);

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

    function compareItems (childIndex:Int, geneIndex:Int) {
        final childGene = Run.inst.nursery.children[childIndex].genes[geneIndex];

        final parent1Gene = Run.inst.nursery.parents[0].genes[geneIndex];
        final parent2Gene = Run.inst.nursery.parents[1].genes[geneIndex];

        final gItem = displayItems[childIndex].gd;

        if (childGene != None) {
            if (parent1Gene == parent2Gene && parent1Gene == childGene) {
                Player.playSound(Assets.sounds.sons_noise3, 0.02);
            } else if (parent1Gene == childGene) {
                Player.playSound(Assets.sounds.sons_fx2, 0.05);
                addUpArrow(gItem.x + geneIndex * 8, gItem.y - 3);
            } else if (parent2Gene == childGene) {
                Player.playSound(Assets.sounds.sons_fx2, 0.05);
                addDownArrow(gItem.x + geneIndex * 8, gItem.y + 3);
            } else {
                addMiddle(gItem.x + geneIndex * 8, gItem.y);
                Player.playSound(Assets.sounds.sons_fx2, 0.05);
                timers.addTimer(0.07, () -> {
                    Player.playSound(Assets.sounds.sons_fx1, 0.05);
                });
            }
        }
    }

    function addUpArrow (x:Float, y:Float) {
        final arrow = new Sprite(x, y, Assets.images.ui, 8, 8);
        arrow.tileIndex = 28;
        arrow.alpha = 0.5;
        arrow.color = 0x249fde;
        entities.push(arrow);
    }

    function addDownArrow (x:Float, y:Float) {
        final arrow = new Sprite(x, y, Assets.images.ui, 8, 8);
        arrow.tileIndex = 29;
        arrow.alpha = 0.5;
        arrow.color = 0x249fde;
        entities.push(arrow);
    }

    function addMiddle (x:Float, y:Float) {
        final spr = new AnimSprite(x, y, Assets.images.ui, 8, 8, 15, [57, 58]);
        spr.alpha = 0.5;
        spr.color = 0xfffc40;
        entities.push(spr);
    }
}
