package game.scenes;

import core.Game;
import core.scene.Scene;
import game.ui.GeneSelectWindow;
import game.ui.UiElement;
import game.ui.UiText;
import game.world.Run;
import kha.Assets;
import kha.graphics2.Graphics;
import kha.input.Mouse;

class SyncScene extends Scene {
    var windows:Array<GeneSelectWindow> = [];
    var topButtons:Array<UiElement> = [];

    var topGuy:GeneSelectWindow;

    override function create () {
        new UiText();
        new Run();

        trace(Run.inst.pool);

        makeTopButtons(1);

        windows.push(topGuy = new GeneSelectWindow(18, 20, 'Partner 1'));

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
        super.update(delta);

        // hovered = false;
        // buttonPressed = false;
        Mouse.get().setSystemCursor(MouseCursor.Default);

        // check top buttons first
        for (button in topButtons) {
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

        for (win in windows) {
            for (c in win.children) {
                // for every button update state and set the tile index if it has a onclick,
                // we assume it is a button.
                if (!c.el.disabled && c.el.visible) {
                    c.el.checkPointer(Game.mouse.position.x, Game.mouse.position.y);
                    if (c.el.onClick != null) {
                        c.el.setIndexFromState();
                        if (c.el.hovered) {
                            Mouse.get().setSystemCursor(MouseCursor.Pointer);
                        }
                        if (c.el.pressed) {
                            // buttonPressed = true;
                            Mouse.get().setSystemCursor(MouseCursor.Pointer);
                        }
                    }
                } else if (c.el.disabled) {
                    c.el.setIndexFromState();
                }

                win.update(delta);
            }
        }
    }

    override function render (g2:Graphics, clears:Bool) {
        g2.begin(true, camera.bgColor);
        for (e in entities) {
            if (e.visible) e.render(g2, camera);
        }
        for (win in windows) if (win.visible) win.render(g2, camera);
        g2.end();
    }

    // TODO: following to parent scene
    function makeTopButtons (sceneIndex:Int) {
        // final button = makeUiButton(64, 0, 32, 16, 16, () -> { trace('click'); });
        // final icon = new Sprite(DayTimeWidth + pos * 32, 0, Assets.images.ui, 32, 32);
        // icon.tileIndex = imgIndex + 48;

        topButtons.push(makeUiTextButton(100, 0, 40, 16, 16, 'BTTL', () -> {
            trace('clicked!');
        }));

        topButtons.push(makeUiTextButton(140, 0, 40, 16, 16, 'SYNC', sceneIndex == 1 ? () -> {
            trace('play sound!');
        } : () -> {
            trace('go scene');
        }));

        topButtons.push(makeUiTextButton(180, 0, 40, 16, 16, 'SHOP', () -> {
            trace('clicked!');
        }));

        // entities.push(icon);
        // entities.push(button);
    }
    function makeUiTextButton (x:Int, y:Int, width:Int, height:Int, tileIndex:Int, text:String, callback:Void -> Void) {
        final button = new UiElement(x, y, 16, 16, 3, 3, 13, 13, width, height, tileIndex, Assets.images.ui, callback);
        final text = makeWhiteText(text);
        text.setPosition(x + Math.floor((width - text.textWidth) / 2), y);
        entities.push(button);
        entities.push(text);
        return button;
    }
}
