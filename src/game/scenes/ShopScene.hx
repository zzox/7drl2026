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

class ShopScene extends UiScene {
    var icon:GuyIcon;
    var genes:GenesDisplay;
    var nameText:BitmapText;
    var remainsText:BitmapText;

    var roster:GeneSelectWindow;

    var buyButton:UiElement;
    var passButton:UiElement;

    var buyCost:BitmapText;

    override function create () {
        // trace(Run.inst.roster);
        super.create();

        makeTopButtons(3);

        // final guy = Run.inst.order[0];

        entities.push(new UiElement(18, 24, 16, 16, 4, 4, 12, 12, 280, 44, 20, Assets.images.ui));

        icon = new GuyIcon(36, 32);
        entities.push(icon);

        genes = new GenesDisplay(52, 40, [], 24);
        entities.push(genes);

        entities.push(nameText = makeBitmapText(52, 28));
        entities.push(remainsText = makeBitmapText(200, 48));

        windows.push(roster = new GeneSelectWindow(18, 100, ' Roster', (num:Int) -> {
            if (num > -1) {}
        }));

        buyButton = makeUiTextButton(80, 76, 40, 16, 16, 'BUYY', () -> {
            Run.inst.doBuy();
            game.changeScene(new ShopScene());
        });

        passButton = makeUiTextButton(200, 76, 40, 16, 16, 'PASS', () -> {
            Run.inst.doPass();
            game.changeScene(new ShopScene());
        });

        buttons.push(buyButton);
        buttons.push(passButton);

        entities.push(buyCost = makeBitmapText(124, 76, '', 0xffffff));

        loadProspect();
    }

    function loadProspect () {
        if (Run.inst.forSale.length > 0) {
            final next = Run.inst.forSale[0];
            icon.dna = next;
            genes.genes = next.genes;
            nameText.setText(next.name);
            buyCost.setText(TextUtil.formatMoney(Run.inst.buyMoney()));
            remainsText.setText('${Run.inst.forSale.length} remain');
        } else {
            entities.push(makeBitmapText(104, 32, 'No more prospects'));
            buyButton.disabled = true;
            passButton.disabled = true;
        }
    }
}
