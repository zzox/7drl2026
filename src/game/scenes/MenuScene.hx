package game.scenes;

import game.ui.UiText;
import game.world.Run;

class MenuScene extends ButtonScene {
    override function create () {
        super.create();

        new UiText();

        entities.push(makeBitmapText(0, 60, 'SONS'));

        final startButton = makeUiTextButton(148, 100, 64, 16, 16, 'STRT', () -> {
            new Run();
            game.changeScene(new GenScene());
        });
        buttons.push(startButton);
    }
}
