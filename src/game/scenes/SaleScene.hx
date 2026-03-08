package game.scenes;

import game.ui.GeneSelectWindow;
import game.ui.UiText;
import game.util.TextUtil;
import game.world.Run;

class SaleScene extends ButtonScene {
    var guy:GuyIcon;

    override function create () {
        super.create();

        final text = makeBitmapText(32, 32, '"${Run.inst.sale.guy.name}" sold for ${TextUtil.formatMoney(Run.inst.sellMoney(Run.inst.sale.guy))}');
        text.x = 180 - Math.floor(text.textWidth / 2);
        entities.push(text);

        guy = new GuyIcon(-16, 48);
        guy.dna = Run.inst.sale.guy;
        guy.frames = 90;

        goRight();

        entities.push(guy);

        buttons.push(makeUiTextButton(140, 100, 40, 16, 16, 'NEXT', () -> {
            launchNextScene();
        }));
    }

    function launchNextScene () {
        Run.inst.handleSale();
        game.changeScene(new RosterScene());
    }

    function goRight () {
        guy.x += 16;
        timers.addTimer(1.0, goRight);
    }
}
