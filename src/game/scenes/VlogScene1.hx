package game.scenes;

import core.Game;
import core.gameobjects.BitmapText;
import core.util.Util;
import game.ui.GenesDisplay;
import game.ui.UiText;
import game.util.Debug;
import game.util.Utils;
import game.world.Room.indexDiff;
import game.world.Run;
import haxe.Timer;
import kha.input.KeyCode;

class VlogScene1 extends ButtonScene {
    public static var gen:Int = 0;

    var logTexts:Array<BitmapText> = [];
    override function create () {
        super.create();

        new Run();

        logTexts[0] = makeBitmapText(4, 4, '');
        logTexts[1] = makeBitmapText(84, 4, '');
        logTexts[2] = makeBitmapText(164, 4, '');

        entities.push(logTexts[0]);
        entities.push(logTexts[1]);
        entities.push(logTexts[2]);

        showFromGen();

#if debug
    Debug.updateTimes = [for (i in 0...300) 0.0]; // ~5 seconds
#end
    }

    override function update (delta:Float) {
#if debug
        final updateStart = Timer.stamp();
#end

        if (Game.keys.justPressed(KeyCode.Up)) {
            gen = ++gen % Run.inst.world.geneCopies.length;
            showFromGen();
        }

        if (Game.keys.justPressed(KeyCode.Down)) {
            gen = --gen;
            if (gen < 0) {
                gen = Run.inst.world.geneCopies.length - 1;
            }
            showFromGen();
        }

        if (Game.keys.justPressed(KeyCode.R)) {
            game.changeScene(new VlogScene1());
        }

        logTexts[0].setText('M: ${Run.inst.world.matches}, S: ${Run.inst.world.stepdads}, N: ${Run.inst.world.pool.length}, ${VlogScene1.gen}');

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

    function showFromGen () {
        entities = entities.slice(0, 3);
        for (i in 0...Run.inst.world.geneCopies[gen].length) {
            final gene = Run.inst.world.geneCopies[gen][i];
            entities.push(new GenesDisplay(2, 20 + 10 * i, gene.genes, 24));
        }
    }
}
