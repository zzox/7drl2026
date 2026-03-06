package game.scenes;

import core.Game;
import game.ui.GeneSelectWindow.GuyIcon;
import game.ui.GenesDisplay;
import game.ui.UiText;
import game.world.Run;

class NurseryScene extends ButtonScene {
    override function create () {
        super.create();

        final p1 = new GuyIcon(16, 16);
        final p2 = new GuyIcon(16, 40);

        p1.dna = Run.inst.nursery.parents[0];
        p2.dna = Run.inst.nursery.parents[1];

        final g1 = new GenesDisplay(32, 24, p1.dna.genes, 24);
        final g2 = new GenesDisplay(32, 48, p2.dna.genes, 24);

        entities.push(p1);
        entities.push(g1);
        entities.push(p2);
        entities.push(g2);

        entities.push(makeBitmapText(32, 12, p1.dna.name));
        entities.push(makeBitmapText(32, 36, p2.dna.name));

        final text = makeBitmapText(32, 36, '${p1.dna.name} and ${p2.dna.name} had ${Run.inst.nursery.children.length} sons');
        text.setPosition(160 - Math.floor(text.textWidth / 2), 48);
        entities.push(text);

        for (i in 0...Run.inst.nursery.children.length) {
            final child = Run.inst.nursery.children[i];

            final icon = new GuyIcon(16, 80 + i * 24);
            icon.dna = child;

            final gd = new GenesDisplay(32, 80 + i * 24 + 8, child.genes, 24);

            entities.push(icon);
            entities.push(gd);
            entities.push(makeBitmapText(32, 80 + i * 24 - 4, child.name));
        }
    }

    override function update (delta:Float) {
        super.update(delta);

        if (Game.mouse.pressed(0)) {
            launchNextScene();
        }
    }

    public function launchNextScene () {
        Run.inst.handleNursery();
        game.changeScene(new SyncScene());
    }
}
