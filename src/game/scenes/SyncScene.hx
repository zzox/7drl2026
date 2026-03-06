package game.scenes;

import game.ui.GeneSelectWindow;
import game.ui.UiElement;
import game.world.Nursery;
import game.world.Run;

class SyncScene extends UiScene {
    var topGuy:GeneSelectWindow;
    var bottomGuy:GeneSelectWindow;

    var syncButton:UiElement;
    var cancelButton:UiElement;

    override function create () {
        trace(Run.inst.roster);

        makeTopButtons(1);

        windows.push(topGuy = new GeneSelectWindow(18, 20, 'Partner 1', (num:Int) -> {
            if (num > -1) {
                bottomGuy.visible = true;
                makeBottomGuy();
            }
        }));
        windows.push(bottomGuy = new GeneSelectWindow(18, 112, 'Partner 2', (num:Int) -> {
            if (num > -1) {}
        }));
        bottomGuy.visible = false;

        syncButton = makeUiTextButton(108, 86, 40, 16, 16, 'SYNC', () -> {
            Run.inst.makeNursery(bottomGuy.selected, topGuy.selected);
            game.changeScene(new NurseryScene());
        });

        cancelButton = makeUiTextButton(172, 86, 40, 16, 16, 'CNCL', () -> {
            topGuy.deselect();
            bottomGuy.deselect();
            bottomGuy.visible = false;
        });

        buttons.push(syncButton);
        buttons.push(cancelButton);

        makeTopGuy();
    }

    override function update (delta:Float) {
        cancelButton.disabled = topGuy.selectedIndex == -1;
        syncButton.disabled = bottomGuy.selectedIndex == -1 || topGuy.selected == bottomGuy.selected;
        super.update(delta);
    }

    function makeTopGuy () {
        for (i in 0...topGuy.items.length) {
            if (Run.inst.roster[i] != null) {
                topGuy.items[i].button.disabled = false;
                topGuy.items[i].icon.dna = Run.inst.roster[i];
            } else {
                topGuy.items[i].button.disabled = true;
                topGuy.items[i].icon.dna = null;
            }
        }
    }

    function makeBottomGuy () {
        for (i in 0...bottomGuy.items.length) {
            if (Run.inst.roster[i] != null) {
                bottomGuy.items[i].button.disabled = false;
                bottomGuy.items[i].icon.dna = Run.inst.roster[i];
            } else {
                bottomGuy.items[i].button.disabled = true;
                bottomGuy.items[i].icon.dna = null;
            }
        }
    }
}
