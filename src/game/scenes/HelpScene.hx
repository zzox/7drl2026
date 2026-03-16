package game.scenes;

import game.ui.UiElement;
import game.ui.UiText;
import game.util.Utils;
import kha.Assets;

class HelpScene extends ButtonScene {
    var screen:Int;

    public function new (screen:Int) {
        super();
        this.screen = screen;
    }

    override function create () {
        super.create();

        final leftButton = new UiElement(104, 4, 16, 16, 4, 4, 12, 12, 16, 16, 64, Assets.images.ui, () -> {
            game.changeScene(new HelpScene(screen - 1));
        });
        final rightButton = new UiElement(200, 4, 16, 16, 4, 4, 12, 12, 16, 16, 48, Assets.images.ui, () -> {
            game.changeScene(new HelpScene(screen + 1));
        });

        leftButton.disabled = screen == 0;
        rightButton.disabled = screen == 3;

        buttons.push(leftButton);
        buttons.push(rightButton);

        entities.push(leftButton);
        entities.push(rightButton);

        buttons.push(makeUiTextButton(140, 160, 40, 16, 16, 'BACK', () -> {
            game.changeScene(new MenuScene());
        }));

        if (screen == 0) {
            makeLabel('Moves');
            entities.push(makeBitmapText(32, 22, 'Step forward'));
            entities.push(makeBitmapText(32, 42, 'Step back'));
            entities.push(makeBitmapText(132, 22, 'Turn towards opponent'));
            entities.push(makeBitmapText(132, 42, 'Turn away from opponent'));

            entities.push(makeBitmapText(32, 64, 'Ranged attack'));
            entities.push(makeBitmapText(32, 84, 'Strong attack, can knock back opponent'));
            entities.push(makeBitmapText(32, 104, 'Attacks in 4 directions'));
            entities.push(makeBitmapText(32, 124, 'Causes opponent to forget next attack'));
            entities.push(makeBitmapText(32, 144, 'Attack with incremental damage'));

            entities.push(makeSpritesheetImage(12, 22, 208));
            entities.push(makeSpritesheetImage(12, 42, 209));
            entities.push(makeSpritesheetImage(112, 22, 210));
            entities.push(makeSpritesheetImage(112, 42, 211));

            entities.push(makeSpritesheetImage(12, 64, 214));
            entities.push(makeSpritesheetImage(12, 84, 213));
            entities.push(makeSpritesheetImage(12, 104, 216));
            entities.push(makeSpritesheetImage(12, 124, 215));
            entities.push(makeSpritesheetImage(12, 144, 212));
        } else if (screen == 1) {
            makeLabel('SYNC');
            entities.push(makeBitmapText(12, 40, 'Sync to create 1-4 sons'));
            entities.push(makeBitmapText(12, 60, 'Parents abandon sons after a sync'));
            entities.push(makeBitmapText(12, 80, 'Radiation increases chance of mutations'));
            entities.push(makeBitmapText(12, 100, 'Without radiation, syncing parents with'));
            entities.push(makeBitmapText(20, 112, 'the same genes will result in the same children'));
        } else if (screen == 2) {
            makeLabel('RSTR');
            entities.push(makeBitmapText(12, 40, 'Sons can be sold for a reduced price'));
            entities.push(makeBitmapText(12, 60, 'Sons genes can be mixed, causes radiation'));
            entities.push(makeBitmapText(12, 80, 'Sons genes can by mutated with an attack gene,'));
            entities.push(makeBitmapText(20, 92, 'causes even more radiation'));
            entities.push(makeBitmapText(20, 120, 'Radiation causes loss of health after battles'));
        } else if (screen == 3) {
            makeLabel('SHOP');
            entities.push(makeBitmapText(12, 80, 'Shops are refreshed after a victory'));
        }
    }

    function makeLabel (label:String) {
        final label = makeBitmapText(0, 4, label, 0xdae0ea);
        label.x = 160 - Math.floor(label.textWidth / 2);
        entities.push(label);
    }
}
