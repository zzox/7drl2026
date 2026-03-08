package game.scenes;

import game.ui.GeneSelectWindow;
import game.ui.UiElement;
import game.world.Nursery;
import game.world.Run;

class SyncScene extends UiScene {
    var partner1:GeneSelectWindow;
    var partner2:GeneSelectWindow;

    var syncButton:UiElement;
    var cancelButton:UiElement;

    override function create () {
        trace(Run.inst.roster);

        makeTopButtons(1);

        windows.push(partner1 = new GeneSelectWindow(18, 20, 'Partner 1', (num:Int) -> {
            if (num > -1) {
                partner2.visible = true;
                makePartner2();
            }
        }));
        windows.push(partner2 = new GeneSelectWindow(18, 112, 'Partner 2', (num:Int) -> {
            if (num > -1) {}
        }));
        partner2.visible = false;

        syncButton = makeUiTextButton(108, 86, 40, 16, 16, 'SYNC', () -> {
            Run.inst.makeNursery(partner2.selected, partner1.selected);
            game.changeScene(new NurseryScene());
        });

        cancelButton = makeUiTextButton(172, 86, 40, 16, 16, 'CNCL', () -> {
            partner1.deselect();
            partner2.deselect();
            partner2.visible = false;
        });

        buttons.push(syncButton);
        buttons.push(cancelButton);

        makePartner1();
    }

    override function update (delta:Float) {
        cancelButton.disabled = partner1.selectedIndex == -1;
        syncButton.disabled = partner2.selectedIndex == -1 || partner1.selected == partner2.selected;
        super.update(delta);
    }

    function makePartner1 () {
        for (i in 0...partner1.items.length) {
            if (Run.inst.roster[i] != null) {
                partner1.items[i].button.disabled = false;
                partner1.items[i].icon.dna = Run.inst.roster[i];
            } else {
                partner1.items[i].button.disabled = true;
                partner1.items[i].icon.dna = null;
            }
        }
    }

    function makePartner2 () {
        for (i in 0...partner2.items.length) {
            if (Run.inst.roster[i] != null) {
                partner2.items[i].button.disabled = false;
                partner2.items[i].icon.dna = Run.inst.roster[i];
            } else {
                partner2.items[i].button.disabled = true;
                partner2.items[i].icon.dna = null;
            }
        }
    }
}
