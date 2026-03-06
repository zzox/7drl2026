package game.scenes;

import core.Game;
import core.scene.Scene;
import game.ui.UiText;

class BattleResultsScene extends Scene {
    override function create () {
        super.create();

        entities.push(makeWhiteText('results are here'));
        // TODO: display results here
    }

    override function update (delta:Float) {
        super.update(delta);

        if (Game.mouse.pressed(0)) {
            launchNextScene();
        }
    }

    public function launchNextScene () {
        // Run.inst.handleResults
        game.changeScene(new PreBattleScene());
    }
}
