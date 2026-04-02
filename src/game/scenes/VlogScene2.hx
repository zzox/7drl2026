package game.scenes;

import core.Game;
import core.gameobjects.BitmapText;
import core.util.Util;
import game.ui.GenesDisplay;
import game.ui.UiText;
import game.util.Debug;
import game.world.Dna;
import game.world.Run;
import game.world.World.simulateBattle;
import haxe.Timer;
import kha.input.KeyCode;

typedef DnaData = {
    var w:Int;
    var l:Int;
    var t:Int;
    var dna:Dna;
}

function score (dna:DnaData) {
    return dna.w * 3 + dna.t;
}

class VlogScene2 extends ButtonScene {
    public static var gen:Int = 0;
    static var seed:Null<Int>;

    var matches:Map<String, Bool> = new Map();
    var dnas:Array<DnaData>;
    var matchNum:Int;

    var logTexts:Array<BitmapText> = [];
    override function create () {
        super.create();

        VlogScene2.seed = VlogScene2.seed ?? Math.floor(Math.random() * 1234567);

        new Run(seed);

        logTexts[0] = makeBitmapText(4, 4, '');
        logTexts[1] = makeBitmapText(84, 4, '');
        logTexts[2] = makeBitmapText(164, 4, '');

        entities.push(logTexts[0]);
        entities.push(logTexts[1]);
        entities.push(logTexts[2]);

        matchNum = Run.inst.world.matches;

        dnas = Run.inst.world.geneCopies[gen].map(d -> {
            return {
                w: 0, l: 0, t: 0, dna: d
            }
        });

        for (d1 in dnas) {
            for (d2 in dnas) {
                if (d2 != d1 && !matches.get('${d2.dna.id}:${d1.dna.id}')) {
                    final res = simulateBattle(d1.dna, d2.dna);
                    if (res == Tie) {
                        d1.t++;
                        d2.t++;
                    } else if (res == OneWin) {
                        d1.w++;
                        d2.l++;
                    } else if (res == TwoWin) {
                        d2.w++;
                        d1.l++;
                    }

                    matchNum++;
                    matches.set('${d1.dna.id}:${d2.dna.id}', true);
                }
            }
        }

        dnas.sort((d1, d2) -> {
            return score(d2) - score(d1);
        });

        show(dnas);


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
            game.changeScene(new VlogScene2());
        }

        if (Game.keys.justPressed(KeyCode.Down)) {
            gen = --gen;
            if (gen < 0) {
                gen = Run.inst.world.geneCopies.length - 1;
            }
            game.changeScene(new VlogScene2());
        }

        if (Game.keys.justPressed(KeyCode.R)) {
            game.changeScene(new VlogScene2());
        }

        logTexts[0].setText('M: ${matchNum}, ${VlogScene2.gen}');

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

    function show (dnas:Array<DnaData>) {
        entities = entities.slice(0, 3);
        for (i in 0...dnas.length) {
            final gene = dnas[i];
            entities.push(new GenesDisplay(2, 20 + 10 * i, gene.dna.genes, 24));
            entities.push(makeBitmapText(204, 16 + 10 * i, 'p: ${score(gene)}, wlt ${gene.w}/${gene.l}/${gene.t}'));
        }
    }
}
