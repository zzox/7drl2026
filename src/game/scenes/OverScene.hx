package game.scenes;

import game.ui.GeneSelectWindow.GuyIcon;
import game.ui.NumColumn;
import game.ui.UiText;
import game.world.Run;

class OverScene extends ButtonScene {
    var winner:Null<GuyIcon>;
    var won:Bool;

    public function new (won:Bool) {
        super();
        this.won = won;
    }

    override function create () {
        super.create();

        final message = won ? 'Victory reached in ${Run.inst.day} days' : 'No more sons';
        final subMessage = if (won) {
            '${Run.inst.defeated.length} wins, ${Run.inst.graveyard.length} losses in ${Run.inst.day + 1} days. you ended with $' + Run.inst.money;
        } else {
            if (Run.inst.graveyard.length == 0) {
                '';
            } else {
                'You lost ${Run.inst.graveyard.length} sons in ${Run.inst.day + 1} days';
            }
        }

        final text = makeBitmapText(0, 32, message);
        text.setPosition(160 - Math.floor(text.textWidth / 2), text.y);
        entities.push(text);

        timers.addTimer(2.0, () -> {
            final subText = makeBitmapText(0, 44, subMessage, 0xb3b9d1);
            subText.setPosition(160 - Math.floor(subText.textWidth / 2), subText.y);
            entities.push(subText);
        });

        final length = Run.inst.roster.length + Run.inst.graveyard.length;

        for (i in 0...length) {
            final row = Math.floor(i / 8);
            final column = i % 8;
            var dead = false;

            final item = if (i < Run.inst.roster.length) {
                if (winner != null) {
                    Run.inst.roster[i];
                } else {
                    Run.inst.roster[i - 1];
                }
            } else {
                dead = true;
                Run.inst.graveyard[i - Run.inst.roster.length];
            }

            final guy = new GuyIcon(96 + column * 16, 64 + row * 16);
            guy.dna = item;
            guy.dead = dead;
            
            if (won && item == Run.inst.room.actors[0].dna) {
                winner = guy;
            }

            entities.push(guy);
        }

        timers.addTimer(3.0, () -> {
            buttons.push(makeUiTextButton(140, 160, 40, 16, 16, 'MENU', () -> {
                game.changeScene(new MenuScene());
            }));
        });

        timers.addTimer(5.0, () -> {
            final stats = new NumColumn(8, 132, 100, ['Wins', 'Losses', 'Offspring', 'Abandoned']);
            stats.color = 0xdae0ea;
            stats.setStringItem('Wins', '${Run.inst.wins}/${Run.Generations + 1}');
            stats.setItem('Losses', Run.inst.losses);
            stats.setItem('Offspring', Run.inst.offspring);
            stats.setItem('Abandoned', Run.inst.abandoned);
            entities.push(stats);
        });
    }

    override function update (delta:Float) {
        super.update(delta);

        if (winner != null) {
            winner.frames++;
        }
    }
}
