package game.scenes;

import game.world.Run;

class MixScene extends ButtonScene {
    override function create () {
        super.create();
        buttons.push(makeUiTextButton(140, 100, 40, 16, 16, 'NEXT', () -> {
            launchNextScene();
        }));
    }

    function launchNextScene () {
        Run.inst.handleMix();
        game.changeScene(new RosterScene());
    }
}
