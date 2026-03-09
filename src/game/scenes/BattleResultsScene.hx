package game.scenes;

import game.ui.GeneSelectWindow.GuyIcon;
import game.ui.UiText;
import game.util.TextUtil;
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

                // since the room isn't handled yet we're calculating it here
                entities.push(makeBitmapText(148, 84, '+${TextUtil.formatMoney(Run.inst.rewardMoney())}', 0x59c135));
                entities.push(makeBitmapText(140, 94, 'HP: ${Run.inst.room.actors[0].dna.hp - Run.inst.room.actors[0].dna.rad}'));
                if (Run.inst.room.actors[0].dna.rad > 0) {
                    entities.push(makeBitmapText(180, 94, '-${Run.inst.room.actors[0].dna.rad}', 0xb4202a));
                }
                entities.push(makeBitmapText(140, 104, 'Rad: ${Run.inst.room.actors[0].dna.rad + 1}'));
                entities.push(makeBitmapText(180, 104, '+1', 0xb4202a));
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

        buttons.push(makeUiTextButton(140, 128, 40, 16, 16, 'NEXT', () -> {
            launchNextScene();
        }));

        // TODO: display results here
    }

    override function update (delta:Float) {
        super.update(delta);

        if (result == Win) {
            time += delta;
            guy.y = Math.floor(time / 2) % 2 == 0 ? 48 : 64;
        }
    }

    public function launchNextScene () {
        Run.inst.handleRoom();
        if (Run.inst.order.length == 0) {
            game.changeScene(new OverScene(true));
        } else if (Run.inst.roster.length == 0) {
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
