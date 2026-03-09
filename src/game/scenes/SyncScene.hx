package game.scenes;

import game.ui.GeneSelectWindow;
import game.ui.GenesDisplay;
import game.ui.UiElement;
import game.world.Nursery;
import game.world.Run;

class SyncScene extends UiScene {
    var partner1:GeneSelectWindow;
    var partner2:GeneSelectWindow;

    var syncButton:UiElement;
    var cancelButton:UiElement;

    var g1:GenesDisplay;
    var g2:GenesDisplay;

    override function create () {
        // trace(Run.inst.roster);
        super.create();

        makeTopButtons(1);

        windows.push(partner1 = new GeneSelectWindow(18, 16, 'Partner 1', (num:Int) -> {
            if (num > -1) {
                partner2.visible = true;
                g1.genes = partner1.selected.genes;
            } else {
                g1.genes = [];
            }
        }));
        windows.push(partner2 = new GeneSelectWindow(18, 76, 'Partner 2', (num:Int) -> {
            if (num > -1) {
                g2.genes = partner2.selected.genes;
            } else {
                g2.genes = [];
            }
        }));
        partner2.visible = false;

        syncButton = makeUiTextButton(108, 162, 40, 16, 16, 'SYNC', () -> {
            Run.inst.makeNursery(partner2.selected, partner1.selected);
            game.changeScene(new NurseryScene());
        });

        cancelButton = makeUiTextButton(172, 162, 40, 16, 16, 'CNCL', () -> {
            partner1.deselect();
            partner2.deselect();
            partner2.visible = false;
        });

        g1 = new GenesDisplay(64, 142, [], 24);
        g2 = new GenesDisplay(64, 152, [], 24);

        entities.push(g1);
        entities.push(g2);

        buttons.push(syncButton);
        buttons.push(cancelButton);
    }

    override function update (delta:Float) {
        cancelButton.disabled = partner1.selectedIndex == -1;
        syncButton.disabled = partner2.selectedIndex == -1 || partner1.selected == partner2.selected;
        super.update(delta);
    }
}
