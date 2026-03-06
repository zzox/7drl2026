package game.scenes;

import core.Game;
import core.scene.Scene;
import game.ui.GeneSelectWindow.GuyIcon;
import game.ui.GenesDisplay;
import game.ui.UiText.makeBitmapText;
import game.world.Run;

class NurseryScene extends Scene {
    override function create () {
        super.create();

        final p1 = new GuyIcon(16, 16);
        final p2 = new GuyIcon(16, 32);

        p1.dna = Run.inst.nursery.parents[0];
        p2.dna = Run.inst.nursery.parents[1];

        final g1 = new GenesDisplay(32, 24, p1.dna.genes);
        final g2 = new GenesDisplay(32, 40, p1.dna.genes);

        entities.push(p1);
        entities.push(g1);
        entities.push(p2);
        entities.push(g2);

        makeBitmapText(32, 16, p1.dna.name);
        makeBitmapText(32, 32, p2.dna.name);
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
