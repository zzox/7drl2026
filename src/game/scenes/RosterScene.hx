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

class RosterScene extends UiScene {
    var chooseGuy:GeneSelectWindow;

    var sellButton:UiElement;
    var mixButton:UiElement;
    var mutateButton:UiElement;

    override function create () {
        trace(Run.inst.roster);

        makeTopButtons(2);

        final guy = Run.inst.order[0];

        entities.push(new UiElement(18, 32, 16, 16, 4, 4, 12, 12, 280, 56, 20, Assets.images.ui));

        final icon = new GuyIcon(50, 40);
        icon.dna = guy;
        entities.push(icon);

        final genes = new GenesDisplay(66, 48, guy.genes, 24);
        entities.push(genes);

        entities.push(makeBitmapText(66, 36, guy.name));
        entities.push(makeBitmapText(192, 36, 'Gen: ${guy.generation}'));

        windows.push(chooseGuy = new GeneSelectWindow(18, 104, ' Select', (num:Int) -> {
            if (num > -1) {}
        }));

        sellButton = makeUiTextButton(40, 64, 40, 16, 16, 'BTTL', () -> {
            // Run.inst.sell(chooseGuy.selected);
            game.changeScene(new RosterScene());
        });

        mixButton = makeUiTextButton(120, 64, 40, 16, 16, 'MIXX', () -> {
            // Run.inst.mix(chooseGuy.selected);
            game.changeScene(new RosterScene());
        });

        mutateButton = makeUiTextButton(180, 64, 40, 16, 16, 'MTXT', () -> {
            // Run.inst.mutate(chooseGuy.selected);
            game.changeScene(new RosterScene());
        });

        buttons.push(sellButton);
        buttons.push(mixButton);
        buttons.push(mutateButton);

        entities.push(makeBitmapText(84, 64, TextUtil.formatMoney(Run.inst.fightNextMoney())));
        entities.push(makeBitmapText(172, 64, TextUtil.formatMoney(Run.inst.skipNextMoney())));
        // entities.push(makeBitmapText(236, 64, 'RWRD:'));
        entities.push(makeBitmapText(272, 64, TextUtil.formatMoney(Run.inst.rewardMoney()), 0x59c135));
    }

    override function update (delta:Float) {
        super.update(delta);
        // fightButton.disabled = chooseGuy.selected == null;
    }
}
