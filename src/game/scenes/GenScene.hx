package game.scenes;

import core.Game;
import core.gameobjects.BitmapText;
import core.util.Util;
import game.ui.GenesDisplay;
import game.ui.UiText;
import game.util.Debug;
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
    Debug.updateTimes = [for (i in 0...300) 0.0]; // ~5 seconds
#end
    }

    override function update (delta:Float) {
#if debug
        final updateStart = Timer.stamp();
#end
        // handleCamera();
        // handlePointer(delta);

        if (Game.keys.justPressed(KeyCode.R)) {
            game.changeScene(new GenScene());
        }

        var steps = 1;
        if (Game.keys.pressed(KeyCode.S)) {
            steps = 0;
        }

        if (Game.keys.justPressed(KeyCode.D)) {
            Run.inst.world.gen();
            Run.inst.world.cull();
        }

        if (Game.keys.justPressed(KeyCode.F)) {
            showGenes();
        }

        if (Game.keys.pressed(KeyCode.G)) {
            game.changeScene(new PreBattleScene());
        }

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

    function showGenes () {
        entities = entities.slice(0, 3);
        for (i in 0...Run.inst.world.geneCopies.length) {
            final gene = Run.inst.world.geneCopies[i];
            // entities.push(makeBitmapText(4, 76 + 10 * i, i + ''));
            entities.push(new GenesDisplay(12, 20 + 10 * i, gene.genes, 24));
            entities.push(makeBitmapText(204, 16 + 10 * i, 'hp: ${gene.hp}, rad: ${gene.rad}'));
        }
    }
}
