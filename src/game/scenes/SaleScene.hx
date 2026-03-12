package game.scenes;

import core.Game;
import game.ui.GeneSelectWindow;
import game.ui.UiText;
import game.util.Player;
import game.util.TextUtil;
import game.world.Run;

class SaleScene extends ButtonScene {
    var guy:GuyIcon;

    override function create () {
        super.create();

        final text = makeBitmapText(32, 32, '"${Run.inst.sale.guy.name}" sold for ${TextUtil.formatMoney(Run.inst.sellMoney(Run.inst.sale.guy))}');
        text.x = 160 - Math.floor(text.textWidth / 2);
        entities.push(text);

        guy = new GuyIcon(-16, 48);
        guy.dna = Run.inst.sale.guy;
        guy.frames = 90;

        goRight();

        entities.push(guy);

        buttons.push(makeUiTextButton(140, 100, 40, 16, 16, 'NEXT', () -> {
            launchNextScene();
        }));

        timers.addTimer(1.0, () -> {
            Player.playCry();
        });

        Game.bgScene.set(0);
    }

    function launchNextScene () {
        Run.inst.handleSale();
        if (Run.inst.roster.length == 0) {
            game.changeScene(new OverScene(false));
        } else {
            game.changeScene(new RosterScene());
        }
    }

    function goRight () {
        guy.x += 16;
        timers.addTimer(1.0, goRight);
    }
}
