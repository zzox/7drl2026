package game.scenes;

import game.ui.UiElement;
import game.ui.UiText.makeBitmapText;
import kha.Assets;

class HelpScene extends ButtonScene {
    var screen:Int;

    public function new (screen:Int) {
        super();
        this.screen = screen;
    }

    override function create () {
        super.create();

        final leftButton = new UiElement(4, 84, 16, 16, 4, 4, 12, 12, 16, 16, 64, Assets.images.ui, () -> {
            game.changeScene(new HelpScene(screen - 1));
        });
        final rightButton = new UiElement(300, 84, 16, 16, 4, 4, 12, 12, 16, 16, 48, Assets.images.ui, () -> {
            game.changeScene(new HelpScene(screen + 1));
        });

        leftButton.disabled = screen == 0;
        rightButton.disabled = screen == 1;

        buttons.push(leftButton);
        buttons.push(rightButton);

        entities.push(leftButton);
        entities.push(rightButton);

        buttons.push(makeUiTextButton(140, 120, 40, 16, 16, 'BACK', () -> {
            game.changeScene(new MenuScene());
        }));

        if (screen == 0) {
            final label = makeBitmapText(0, 4, 'Basic', 0xdae0ea);
            label.x = 160 - Math.floor(label.textWidth / 2);
            entities.push(label);

            entities.push(makeBitmapText(12, 20, 'Mixing and Mutating create radiation'));
            entities.push(makeBitmapText(12, 32, 'Winning battles create more radiation'));
            entities.push(makeBitmapText(12, 44, 'Radiation increases chances of mutations, but'));
            entities.push(makeBitmapText(20, 54, 'decreases health after a battle'));
            entities.push(makeBitmapText(12, 66, 'Syncing parents with the same genes will result in'));
            entities.push(makeBitmapText(20, 76, 'the same children.'));
            entities.push(makeBitmapText(12, 88, 'Shops are refreshed after a victory'));
        }
    }
}
