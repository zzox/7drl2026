package game.scenes;

import game.ui.GeneSelectWindow.GuyIcon;
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

        final text = makeBitmapText(0, 32, message);
        text.setPosition(160 - Math.floor(text.textWidth / 2), text.y);
        entities.push(text);

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

            final guy = new GuyIcon(96 + column * 16, 48 + row * 16);
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
    }

    override function update (delta:Float) {
        super.update(delta);

        if (winner != null) {
            winner.frames++;
        }
    }
}
