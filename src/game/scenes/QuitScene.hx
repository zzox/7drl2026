package game.scenes;

import game.ui.UiText.makeBitmapText;
import kha.Assets;

class QuitScene extends ButtonScene {
    override function create () {
        super.create();

        final text = makeBitmapText(0, 32, 'Abandon Run?');
        text.setPosition(160 - Math.floor(text.textWidth / 2), text.y);
        entities.push(text);

        final subText = makeBitmapText(0, 44, 'All progress will be lost', 0xb3b9d1);
        subText.setPosition(160 - Math.floor(subText.textWidth / 2), subText.y);
        entities.push(subText);

        final item = makeUiTextButton(100, 120, 40, 16, 16, 'QUIT', () -> {
            game.changeScene(new MenuScene());
        });
        item.altSound = Assets.sounds.sons_fx2;
        buttons.push(item);

        buttons.push(makeUiTextButton(180, 120, 40, 16, 16, 'BACK', () -> {
            game.changeScene(new StatsScene());
        }));
    }
}
