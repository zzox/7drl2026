package game.scenes;

import core.Game;
import game.data.Save;
import game.ui.UiText;

class ClickFocusScene extends ButtonScene {
    override function create () {
        super.create();
        new UiText();
        new Save();

        final text = makeBitmapText(0, 72, 'Click to focus window');
        text.setPosition(160 - Math.floor(text.textWidth / 2), text.y);
        entities.push(text);
    }

    override function update (delta:Float) {
        super.update(delta);

        if (Game.mouse.pressed(0)) {
            launchNextScene();
        }
    }

    public function launchNextScene () {
#if harness
        game.changeScene(new HarnessScene());
#else
        game.changeScene(new MenuScene());
#end
    }
}
