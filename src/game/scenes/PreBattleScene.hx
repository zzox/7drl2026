package game.scenes;

import core.Game;
import game.ui.GeneSelectWindow;
import game.ui.UiElement;
import game.ui.UiText;
import game.world.Dna;
import game.world.Run;
import kha.input.Mouse;

class PreBattleScene extends UiScene {
    var chooseGuy:GeneSelectWindow;

    var runButton:UiElement;

    override function create () {
        trace(Run.inst.pool);

        makeTopButtons(0);

        windows.push(chooseGuy = new GeneSelectWindow(18, 100, 'Fighter', (num:Int) -> {
            if (num > -1) {}
        }));

        runButton = makeUiTextButton(48, 92, 40, 16, 16, 'BTTL', () -> {
            trace('launch battle scene');
            Run.inst.makeRoom(chooseGuy.selected, new Dna());
            game.changeScene(new BattleScene());
        });

        buttons.push(runButton);

        makeChooseGuy();
    }

    function makeChooseGuy () {
        for (i in 0...chooseGuy.items.length) {
            if (Run.inst.pool[i] != null) {
                chooseGuy.items[i].button.disabled = false;
                chooseGuy.items[i].icon.dna = Run.inst.pool[i];
            } else {
                chooseGuy.items[i].button.disabled = true;
                chooseGuy.items[i].icon.dna = null;
            }
        }
    }
}
