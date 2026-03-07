package game.scenes;

import core.Game;
import core.gameobjects.BitmapText;
import core.scene.Scene;
import game.ui.GeneSelectWindow;
import game.ui.UiElement;
import game.ui.UiText;
import game.util.TextUtil;
import game.world.Run;
import kha.Assets;
import kha.graphics2.Graphics;
import kha.input.Mouse;

class UiScene extends ButtonScene {
    var windows:Array<GeneSelectWindow> = [];
    var moneyText:BitmapText;

    override function update (delta:Float) {
        super.update(delta);

        moneyText.setText(TextUtil.formatMoney(Run.inst.money));
        moneyText.x = 320 - moneyText.textWidth - 4;

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

    function makeTopButtons (sceneIndex:Int) {
        entities.push(new UiElement(0, 0, 16, 16, 4, 4, 12, 12, 64, 16, 25, Assets.images.ui));
        entities.push(new UiElement(320 - 64, 0, 16, 16, 4, 4, 12, 12, 64, 16, 25, Assets.images.ui));

        buttons.push(makeUiTextButton(100, 0, 40, 16, sceneIndex == 0 ? 37 : 16, 'BTTL', sceneIndex == 0 ? null : () -> {
            game.changeScene(new PreBattleScene());
        }));

        buttons.push(makeUiTextButton(140, 0, 40, 16, sceneIndex == 1 ? 37 : 16, 'SYNC', sceneIndex == 1 ? null : () -> {
            game.changeScene(new SyncScene());
        }));

        buttons.push(makeUiTextButton(180, 0, 40, 16, 16, 'SHOP', () -> {
            trace('clicked!');
        }));

        moneyText = makeBitmapText(0, 0, TextUtil.formatMoney(Run.inst.money), 0xfffc40);
        moneyText.x = 320 - moneyText.textWidth - 4;

        entities.push(makeBitmapText(4, 0, 'Day ${Run.inst.day}', 0xdae0ea));
        entities.push(moneyText);
    }
}
