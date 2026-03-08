package game.scenes;

import core.Game;
import core.gameobjects.BitmapText;
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

    var sellCost:BitmapText;
    var mixCost:BitmapText;
    var mutateCost:BitmapText;

    override function create () {
        trace(Run.inst.roster);

        makeTopButtons(2);

        // final guy = Run.inst.order[0];

        // final icon = new GuyIcon(50, 40);
        // icon.dna = guy;
        // entities.push(icon);

        // final genes = new GenesDisplay(66, 48, guy.genes, 24);
        // entities.push(genes);

        // entities.push(makeBitmapText(66, 36, guy.name));
        // entities.push(makeBitmapText(192, 36, 'Gen: ${guy.generation}'));

        entities.push(new UiElement(18, 112, 16, 16, 4, 4, 12, 12, 280, 44, 20, Assets.images.ui));

        windows.push(chooseGuy = new GeneSelectWindow(18, 32, '  Select', (num:Int) -> {
            final sellMoney = Run.inst.sellMoney(chooseGuy.selected);
            final mixMoney = Run.inst.mixMoney(chooseGuy.selected);
            final mutateMoney = Run.inst.mutateMoney(chooseGuy.selected);

            sellCost.setText(TextUtil.formatMoney(sellMoney));
            mixCost.setText(TextUtil.formatMoney(mixMoney));
            mutateCost.setText(TextUtil.formatMoney(mutateMoney));

            sellButton.disabled = false;
            mixButton.disabled = mixMoney > Run.inst.money;
            mutateButton.disabled = mutateMoney > Run.inst.money;
        }));

        sellButton = makeUiTextButton(40, 124, 40, 16, 16, 'SELL', () -> {
            Run.inst.sell(chooseGuy.selected);
            game.changeScene(new RosterScene());
        });

        mixButton = makeUiTextButton(124, 124, 40, 16, 16, 'MIXX', () -> {
            Run.inst.doMix(chooseGuy.selected);
            game.changeScene(new MixScene());
        });

        mutateButton = makeUiTextButton(208, 124, 40, 16, 16, 'MTXT', () -> {
            Run.inst.doMutate(chooseGuy.selected);
            game.changeScene(new MutationScene());
        });

        sellButton.disabled = true;
        mixButton.disabled = true;
        mutateButton.disabled = true;

        buttons.push(sellButton);
        buttons.push(mixButton);
        buttons.push(mutateButton);

        entities.push(sellCost = makeBitmapText(84, 124, '', 0x59c135));
        entities.push(mixCost = makeBitmapText(168, 124, ''));
        entities.push(mutateCost = makeBitmapText(244, 124, ''));
    }

    override function update (delta:Float) {
        super.update(delta);
        // fightButton.disabled = chooseGuy.selected == null;
    }
}
