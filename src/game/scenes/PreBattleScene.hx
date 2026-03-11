package game.scenes;

import core.Game;
import game.ui.GeneSelectWindow;
import game.ui.GenesDisplay;
import game.ui.UiElement;
import game.ui.UiText;
import game.util.TextUtil;
import game.world.Dna;
import game.world.Run;
import kha.Assets;
import kha.input.Mouse;

class PreBattleScene extends UiScene {
    var chooseGuy:GeneSelectWindow;

    var fightButton:UiElement;
    var skipButton:UiElement;

    override function create () {
        // trace(Run.inst.roster);
        super.create();

        makeTopButtons(0);

        final guy = Run.inst.order[0];

        entities.push(new UiElement(18, 32, 16, 16, 4, 4, 12, 12, 280, 56, 20, Assets.images.ui));

        final icon = new GuyIcon(50, 40);
        icon.dna = guy;
        entities.push(icon);

        final genes = new GenesDisplay(66, 48, guy.genes, 24);
        entities.push(genes);

        entities.push(makeBitmapText(66, 36, guy.name));
        entities.push(makeBitmapText(192, 36, 'Gen: ${guy.generation}'));

        windows.push(chooseGuy = new GeneSelectWindow(18, 104, ' Fighter', (num:Int) -> {
            if (num > -1) {}
        }));

        fightButton = makeUiTextButton(40, 64, 40, 16, 16, 'BTTL', () -> {
            Run.inst.fightNext(chooseGuy.selected);
            game.changeScene(new BattleScene());
        });
        fightButton.disabled = true;
        fightButton.altSound = Assets.sounds.sons_noise1;

        skipButton = makeUiTextButton(124, 64, 40, 16, 16, 'SKIP', () -> {
            Run.inst.skipNext();
            game.changeScene(new PreBattleScene());
        });
        skipButton.disabled = Run.inst.money < Run.inst.skipNextMoney();

        buttons.push(fightButton);
        buttons.push(skipButton);

        // entities.push(makeBitmapText(84, 64, TextUtil.formatMoney(Run.inst.fightNextMoney())));
        entities.push(makeBitmapText(168, 64, TextUtil.formatMoney(Run.inst.skipNextMoney())));
        entities.push(makeBitmapText(224, 64, 'RWRD:'));
        entities.push(makeBitmapText(256, 64, TextUtil.formatMoney(Run.inst.rewardMoney()), 0x59c135));
    }

    override function update (delta:Float) {
        super.update(delta);
        fightButton.disabled = chooseGuy.selected == null;
    }
}
