package game.scenes;

import game.world.Run;

class MutationScene extends ButtonScene {
    override function create () {
        super.create();
        buttons.push(makeUiTextButton(140, 100, 40, 16, 16, 'NEXT', () -> {
            launchNextScene();
        }));
    }

    function launchNextScene () {
        Run.inst.handleMutate();
        game.changeScene(new RosterScene());
    }
}
