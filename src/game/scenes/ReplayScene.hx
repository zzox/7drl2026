package game.scenes;

import core.Game;
import core.gameobjects.BitmapText;
import core.util.Util;
import game.ui.UiText;
import game.util.Debug;
import game.world.Run;
import haxe.Json;
import haxe.Timer;
import kha.input.KeyCode;

// following 2 are obsolete
// difficulty: 2
// final replay = '{"commands":[{"day":0,"command":{"type":0,"dId":4}},{"day":1,"command":{"type":0,"dId":3}},{"day":2,"command":{"type":0,"dId":3}},{"day":3,"command":{"type":0,"dId":4}},{"day":4,"command":{"type":0,"dId":4}},{"day":5,"command":{"type":0,"dId":4}},{"day":6,"command":{"type":5,"dId":5}},{"day":6,"command":{"type":5,"dId":5}},{"day":6,"command":{"type":2,"dId1":5,"dId2":2}},{"day":7,"command":{"type":6}},{"day":7,"command":{"type":5,"dId":1939}},{"day":7,"command":{"type":5,"dId":1942}},{"day":7,"command":{"type":2,"dId1":1942,"dId2":1939}},{"day":8,"command":{"type":3,"dId":1943}},{"day":8,"command":{"type":0,"dId":1944}},{"day":9,"command":{"type":5,"dId":3}},{"day":9,"command":{"type":5,"dId":3}},{"day":9,"command":{"type":5,"dId":3}},{"day":9,"command":{"type":2,"dId1":3,"dId2":1944}},{"day":10,"command":{"type":0,"dId":4}},{"day":11,"command":{"type":0,"dId":1951}},{"day":12,"command":{"type":0,"dId":1952}},{"day":13,"command":{"type":0,"dId":1950}},{"day":14,"command":{"type":5,"dId":1953}},{"day":14,"command":{"type":4,"dId":1951}},{"day":14,"command":{"type":4,"dId":1951}},{"day":14,"command":{"type":2,"dId1":1951,"dId2":1953}},{"day":15,"command":{"type":0,"dId":1961}},{"day":16,"command":{"type":0,"dId":1961}},{"day":17,"command":{"type":0,"dId":1959}},{"day":18,"command":{"type":0,"dId":1960}},{"day":19,"command":{"type":0,"dId":1960}},{"day":20,"command":{"type":6}},{"day":20,"command":{"type":6}},{"day":20,"command":{"type":6}},{"day":20,"command":{"type":3,"dId":1964}},{"day":20,"command":{"type":5,"dId":1966}},{"day":20,"command":{"type":2,"dId1":1965,"dId2":1960}},{"day":21,"command":{"type":2,"dId1":1967,"dId2":1966}},{"day":22,"command":{"type":0,"dId":1968}},{"day":23,"command":{"type":0,"dId":1969}},{"day":24,"command":{"type":0,"dId":1970}},{"day":25,"command":{"type":0,"dId":1970}}],"day":26,"seed":888105,"sons":0}';
// difficulty: 1.5
final replay = '{"commands":[{"day":0,"command":{"type":0,"dId":3}},{"day":1,"command":{"type":0,"dId":4}},{"day":2,"command":{"type":5,"dId":3}}],"day":2,"seed":1088740,"sons":4}';

class ReplayScene extends ButtonScene {
    var logTexts:Array<BitmapText> = [];
    var commands:Array<{ day:Int, command:Command }>;
    override function create () {
        super.create();

        final parsed = Json.parse(replay);

        new Run(parsed.seed);

        commands = parsed.commands;

        logTexts[0] = makeBitmapText(4, 4, '');
        logTexts[1] = makeBitmapText(4, 14, '');
        logTexts[2] = makeBitmapText(4, 24, '');

        for (l in logTexts) {
            entities.push(l);
        }

#if debug
    Debug.updateTimes = [for (i in 0...300) 0.0]; // ~5 seconds
#end
    }

    override function update (delta:Float) {
#if debug
        final updateStart = Timer.stamp();
#end

        if (Game.keys.justPressed(KeyCode.R)) {
            game.changeScene(new ReplayScene());
        }

        if (commands.length > 0) {
            // trace(commands[0], Run.inst.roster[0].name);
            Run.inst.doCommand(commands.shift().command, true);

            if (commands.length == 0) {
                for (r in Run.inst.roster) {
                    trace(r.name);
                }
            }
        }

        logTexts[0].setText(commands.length + '');
        logTexts[1].setText(Run.inst.roster.length + '');

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
}
