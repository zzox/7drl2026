package game.scenes;

import core.scene.Scene;
import game.ui.UiText;

class BattleResultsScene extends Scene {
    override function create () {
        super.create();

        entities.push(makeWhiteText('results are here'));
    }
}
