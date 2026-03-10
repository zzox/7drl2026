package game.scenes;

import game.ui.UiElement;
import game.ui.UiText;
import game.world.Run;
import kha.Assets;

class QuitScene extends UiScene {
    override function create () {
        makeTopButtons(4);

        entities.push(new UiElement(18, 64, 16, 16, 4, 4, 12, 12, 280, 56, 20, Assets.images.ui));

        entities.push(makeBitmapText(66, 68, 'Are you sure you want to quit?'));

        final item = makeUiTextButton(140, 92, 40, 16, 16, 'QUIT', () -> {
            game.changeScene(new MenuScene());
            // game.changeScene(new ReallyQuitScene());
        });
        item.altSound = Assets.sounds.sons_fx2;
        buttons.push(item);
    }
}
