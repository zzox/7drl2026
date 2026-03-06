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

class UiScene extends ButtonScene {
    var windows:Array<GeneSelectWindow> = [];

    override function update (delta:Float) {
        super.update(delta);

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

        buttons.push(makeUiTextButton(100, 0, 40, 16, 16, 'BTTL', sceneIndex == 0 ? () -> {
            trace('play sound!');
        } : () -> {
            game.changeScene(new PreBattleScene());
        }));

        buttons.push(makeUiTextButton(140, 0, 40, 16, 16, 'SYNC', sceneIndex == 1 ? () -> {
            trace('play sound!');
        } : () -> {
            game.changeScene(new SyncScene());
        }));

        buttons.push(makeUiTextButton(180, 0, 40, 16, 16, 'SHOP', () -> {
            trace('clicked!');
        }));

        // entities.push(icon);
        // entities.push(button);
    }
}
