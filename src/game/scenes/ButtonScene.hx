package game.scenes;

import core.Game;
import core.scene.Scene;
import game.ui.UiElement;
import game.ui.UiText;
import kha.Assets;
import kha.input.KeyCode;
import kha.input.Mouse;

class ButtonScene extends Scene {
    var buttons:Array<UiElement> = [];

    override function update (delta:Float) {
        Mouse.get().setSystemCursor(MouseCursor.Default);
        super.update(delta);

        // check top buttons first
        for (button in buttons) {
            if (!button.disabled && button.visible) {
                button.checkPointer(Game.mouse.position.x, Game.mouse.position.y);
                if (button.onClick != null) {
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
            } else if (button.disabled) {
                button.setIndexFromState();
            }

            // mark if we hovered over any of these or if an item was pressed
            // if (b.button.pressed) {
            //     hovered = true;
            // }
        }
    }

    function makeUiTextButton (x:Int, y:Int, width:Int, height:Int, tileIndex:Int, text:String, callback:Void -> Void):UiElement {
        final button = new UiElement(x, y, 16, 16, 3, 3, 13, 13, width, height, tileIndex, Assets.images.ui, callback);
        final text = makeWhiteText(text);
        text.setPosition(x + Math.floor((width - text.textWidth) / 2), y);
        entities.push(button);
        entities.push(text);
        return button;
    }
}
