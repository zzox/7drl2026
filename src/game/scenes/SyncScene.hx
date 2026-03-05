package game.scenes;

import core.Game;
import game.ui.GeneSelectWindow;
import game.ui.UiElement;
import game.ui.UiText;
import game.world.Run;
import kha.input.Mouse;

class SyncScene extends UiScene {
    var topGuy:GeneSelectWindow;
    var bottomGuy:GeneSelectWindow;

    var syncButton:UiElement;
    var cancelButton:UiElement;

    override function create () {
        new UiText();
        new Run();

        trace(Run.inst.pool);

        makeTopButtons(1);

        windows.push(topGuy = new GeneSelectWindow(18, 20, 'Partner 1', (num:Int) -> {
            if (num > -1) {
                bottomGuy.visible = true;
            }
        }));
        windows.push(bottomGuy = new GeneSelectWindow(18, 100, 'Partner 2', (num:Int) -> {
            if (false) {}
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

    override function update (delta:Float) {
        cancelButton.disabled = topGuy.selectedIndex == -1;
        syncButton.disabled = bottomGuy.selectedIndex == -1;

        for (button in [syncButton, cancelButton]) {
            button.checkPointer(Game.mouse.position.x, Game.mouse.position.y);
            if (!button.disabled && button.onClick != null) {
                button.setIndexFromState();
                if (button.hovered) {
                    // hovered = true;
                    Mouse.get().setSystemCursor(MouseCursor.Pointer);
                }
                if (button.pressed) {
                    // buttonPressed = true;
                    Mouse.get().setSystemCursor(MouseCursor.Pointer);
                }
            }

            // mark if we hovered over any of these or if an item was pressed
            // if (b.button.pressed) {
            //     hovered = true;
            // }
        }

        super.update(delta);
    }
}
