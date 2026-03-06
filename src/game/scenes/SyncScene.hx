package game.scenes;

import game.ui.GeneSelectWindow;
import game.ui.UiElement;
import game.world.Run;

class SyncScene extends UiScene {
    var topGuy:GeneSelectWindow;
    var bottomGuy:GeneSelectWindow;

    var syncButton:UiElement;
    var cancelButton:UiElement;

    override function create () {
        trace(Run.inst.pool);

        makeTopButtons(1);

        windows.push(topGuy = new GeneSelectWindow(18, 20, 'Partner 1', (num:Int) -> {
            if (num > -1) {
                bottomGuy.visible = true;
                makeBottomGuy();
            }
        }));
        windows.push(bottomGuy = new GeneSelectWindow(18, 100, 'Partner 2', (num:Int) -> {
            if (num > -1) {}
        }));
        bottomGuy.visible = false;

        syncButton = makeUiTextButton(48, 92, 40, 16, 16, 'SYNC', () -> {
            trace('launch sync scene');
        });

        cancelButton = makeUiTextButton(172, 92, 40, 16, 16, 'CNCL', () -> {
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
        syncButton.disabled = bottomGuy.selectedIndex == -1;
        super.update(delta);
    }

    function makeTopGuy () {
        for (i in 0...topGuy.items.length) {
            if (Run.inst.pool[i] != null) {
                topGuy.items[i].button.disabled = false;
                topGuy.items[i].icon.dna = Run.inst.pool[i];
            } else {
                topGuy.items[i].button.disabled = true;
                topGuy.items[i].icon.dna = null;
            }
        }
    }

    function makeBottomGuy () {
        final items = Run.inst.pool.filter(i -> i != bottomGuy.selected);
        for (i in 0...bottomGuy.items.length) {
            if (items[i] != null) {
                bottomGuy.items[i].button.disabled = false;
                bottomGuy.items[i].icon.dna = items[i];
            } else {
                bottomGuy.items[i].button.disabled = true;
                bottomGuy.items[i].icon.dna = null;
            }
        }
    }
}
