package game.scenes;

import core.Game;
import core.scene.Scene;
import game.ui.GeneSelectWindow.GuyIcon;
import game.ui.UiText;
import game.world.Run;

enum Result {
    Win;
    Loss;
    Tie;
}

class BattleResultsScene extends ButtonScene {
    var guy:GuyIcon;
    var time:Float = 0.0;
    var result:Result;

    override function create () {
        super.create();

        guy = new GuyIcon(152, 48);
        guy.dna = Run.inst.room.actors[0].dna;

        var message = 'was killed';
        if (Run.inst.room.actors[0].hp <= 0) {
            result = Loss;
            guy.dead = true;
        } else {
            if (Run.inst.room.actors[1].hp <= 0) {
                message = 'won';
                result = Win;
            } else {
                message = 'survived';
                result = Tie;
                guy.frames = 270;
                goHome();
            }
        }

        final text = makeBitmapText(0, 32, '${Run.inst.room.actors[0].dna.name} ${message}');
        text.setPosition(160 - Math.floor(text.textWidth / 2), text.y);

        entities.push(text);
        entities.push(guy);

        buttons.push(makeUiTextButton(140, 100, 40, 16, 16, 'NEXT', () -> {
            launchNextScene();
        }));

        // TODO: display results here
    }

    override function update (delta:Float) {
        super.update(delta);

        if (result == Win) {
            time += delta;
            guy.y = Math.floor(time / 6) % 2 == 0 ? 48 : 64;
        }
    }

    public function launchNextScene () {
        Run.inst.handleRoom();
        if (Run.inst.roster.length == 0) {
            game.changeScene(new OverScene(false));
        } else {
            game.changeScene(new PreBattleScene());
        }
    }

    public function goHome () {
        timers.addTimer(1.0, () -> {
            guy.x -= 16;
            goHome();
        });
    }
}
