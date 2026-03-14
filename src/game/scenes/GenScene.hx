package game.scenes;

import core.Game;
import core.gameobjects.BitmapText;
import core.util.Util;
import game.ui.GenesDisplay;
import game.ui.UiText;
import game.util.Debug;
import game.util.Utils;
import game.world.Run;
import haxe.Timer;
import kha.input.KeyCode;

class GenScene extends ButtonScene {
    var logTexts:Array<BitmapText> = [];
    override function create () {
        super.create();

        logTexts[0] = makeBitmapText(4, 4, '');
        logTexts[1] = makeBitmapText(180, 4, '');
        logTexts[2] = makeBitmapText(4, 14, '');

        entities.push(logTexts[0]);
        entities.push(logTexts[1]);
        entities.push(logTexts[2]);

#if debug
        for (i in 0...(Run.Generations + 1)) {
            timers.addTimer(0.5 + (i * 0.1) * 1.1, () -> {
                showGenes(i + 1);

                if (i == Run.Generations) {
                    goNextScene();
                }
            });
        }
#else
        for (i in 0...(Run.Generations + 1)) {
            timers.addTimer(1.5 + (i * 0.3) * 1.1, () -> {
                Run.inst.world.gen();
                Run.inst.world.cull();
                showGenes(i + 1);

                if (i == Run.Generations) {
                    goNextScene();
                }
            });
        }
#end

#if debug
    Debug.updateTimes = [for (i in 0...300) 0.0]; // ~5 seconds
#end
    }

    override function update (delta:Float) {
#if debug
        final updateStart = Timer.stamp();
#end
        logTexts[0].setText('Creating family trees...');
        logTexts[1].setText('M: ${Run.inst.world.matches}, G: ${Run.inst.world.generation}, N: ${Run.inst.world.pool.length}');

        super.update(delta);

#if debug
        final time = Timer.stamp();
        final updateTime = time - updateStart;
        Debug.updateTimes.push(updateTime);
        Debug.updateTimes.shift();

        Debug.updateFrames.push(time);
        while (true) {
            if (Debug.updateFrames[0] != null && Debug.updateFrames[0] < time - 0.999) {
                Debug.updateFrames.shift();
            } else {
                break;
            }
        }

        final highest = Lambda.fold(Debug.updateTimes, (frame, res) -> Math.max(frame, res), 0);
        logTexts[2].setText('UPS: ${Debug.updateFrames.length}, avg: ${Math.round(average(Debug.updateTimes) * 1000)}ms, hi: ${Math.round(highest * 1000)}ms');
#end
    }

    function showGenes (num:Int) {
        entities = entities.slice(0, 3);
        for (i in 0...num) {
            final gene = getRandomItem(Run.inst.world.geneCopies[i]);
            // entities.push(makeBitmapText(4, 76 + 10 * i, i + ''));
            entities.push(new GenesDisplay(12 + i * 2, 20 + 10 * i, gene.genes, 24));
            entities.push(makeBitmapText(204 + i * 2, 16 + 10 * i, 'n: ${Run.inst.world.geneCopies[i].length}'));
        }
    }

    function goNextScene () {
        timers.addTimer(1.0, () -> {
            game.changeScene(new PreBattleScene());
        });
    }
}
