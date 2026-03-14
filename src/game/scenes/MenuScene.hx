package game.scenes;

import core.Game;
import core.gameobjects.SImage;
import game.ui.UiText;
import game.world.Run;
import kha.Assets;

class MenuScene extends ButtonScene {
    override function create () {
        super.create();

        new UiText();

        entities.push(new SImage(40, 20, Assets.images.sons1));

        buttons.push(makeUiTextButton(140, 100, 40, 16, 16, 'STRT', () -> {
            new Run();
            game.changeScene(new GenScene());
        }));

        buttons.push(makeUiTextButton(140, 124, 40, 16, 16, 'HELP', () -> {
            game.changeScene(new HelpScene(0));
        }));

        Game.bgScene.set(2);
    }
}
