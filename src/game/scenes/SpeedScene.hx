package game.scenes;

import core.Game;
import core.gameobjects.BitmapText;
import core.scene.Scene;
import core.util.Util;
import game.ui.GenesDisplay;
import game.ui.UiText;
import game.util.Debug;
import game.world.World;
import haxe.Json;
import haxe.Timer;
import kha.input.KeyCode;
import kha.math.Random;

final json = '[{ temp: 1 }]';

class SpeedScene extends Scene {
    var world:World;
    // var worldActive:Bool = true;

    var devTexts:Array<BitmapText> = [];

    var genes1:GenesDisplay;
    var genes2:GenesDisplay;

    // var replayCommands:Array<{ step:Int, command: Command }>;

    var canGo:Bool = true;

    override function create () {
        super.create();

        // WARN: should go in first scene in the game to initialize these items
        new UiText();

        for (i in 0...20) {
            final text = makeBitmapText(4, 4 + i * 10, '');
            entities.push(text);
            devTexts.push(text);
        }

        // trace(names.map(n -> shuffle(n.split(''), new Random(666)).join('')));

        // final parsed = Json.parse(json);
        // world = new World(parsed.seed);
        world = new World();

        entities.push(genes1 = new GenesDisplay(4, 80, world.room.actors[0].dna.genes, 24));
        entities.push(genes2 = new GenesDisplay(4, 90, world.room.actors[1].dna.genes, 24));

        // trace(Std.isOfType(replayCommands, Array<{ step:Int, command: Command }>));
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
            game.changeScene(new SpeedScene());
        }

        var steps = 1;
        if (Game.keys.pressed(KeyCode.S)) {
            steps = 0;
        }

        if (Game.keys.pressed(KeyCode.D)) {
            steps = 10;
        }

        if (Game.keys.pressed(KeyCode.F)) {
            steps = 100;
        }

        if (Game.keys.pressed(KeyCode.G)) {
            steps = 1000;
        }

        if (canGo && steps > 0) {
            for (_ in 0...steps) {
                while (world.room.checkDead() == 0 && !world.room.checkSkip()) {
                    world.room.step(0);
                }
                canGo = world.nextRoom();
                if (!canGo) {
                    showGenes();
                }
            }
        }

        genes1.dIndex = world.room.actors[0].dnaIndex;
        genes2.dIndex = world.room.actors[1].dnaIndex;

        genes1.genes = world.room.actors[0].dna.genes;
        genes2.genes = world.room.actors[1].dna.genes;

        devTexts[0].setText('Matches: ${world.matches}');
        devTexts[1].setText('Remains: ${world.pool.length + world.winners.length}');
        devTexts[2].setText('Gen: ${world.generation}');
        devTexts[3].setText('step: ${world.stepdads}');
        devTexts[4].setText('${world.room.actors[0].dna.id} vs ${world.room.actors[1].dna.id}');
        devTexts[5].setText('${world.room.steps}');

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
        devTexts[6].setText('UPS: ${Debug.updateFrames.length}, avg: ${Math.round(average(Debug.updateTimes) * 1000)}ms, hi: ${Math.round(highest * 1000)}ms');
#end
    }

    function showGenes () {
        // ;p;
        entities = entities.filter(e -> e != genes1 && e != genes2);

        for (i in 0...world.geneCopies.length) {
            final gene = world.geneCopies[i];
            entities.push(makeBitmapText(4, 76 + 10 * i, i + ''));
            entities.push(genes1 = new GenesDisplay(12, 80 + 10 * i, gene.genes, 24));
            entities.push(makeBitmapText(204, 76 + 10 * i, 'hp: ${gene.hp}, sp: ${gene.speed}'));
        }
    }
}
