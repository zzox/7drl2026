package game.scenes;

import core.Game;
import core.Types;
import core.gameobjects.BitmapText;
import core.scene.Scene;
import game.ui.GenesDisplay;
import game.ui.NumColumn;
import game.ui.RoomRender;
import game.ui.UiText;
import game.util.Debug;
import game.world.Actor;
import game.world.Room.RoomEvent;
import game.world.Run;
import game.world.Thing;
import haxe.Json;
import haxe.Timer;
import kha.graphics2.Graphics;
import kha.input.KeyCode;

class BattleScene extends Scene {
    public static final White:Int = 256 * 0x1000000 + 0xffffffff;

    static var pulseTime:Float = 0.0;
    public static var pulseOn:Bool = true;
    public static var shortPulseOn:Bool = true;

    // var uiScene:UiScene;
    // var logs:Logs;
    var worldActive:Bool = true;
    var tilePosAt:IntVec2 = new IntVec2(0, 0);

    var stepCounter:Int = 0;

    var stepText:BitmapText;
    // var winsText:BitmapText;
    var char1:NumColumn;
    var char2:NumColumn;
    var genes1:GenesDisplay;
    var genes2:GenesDisplay;

    // var renderedActors:Array<RenderedActor> = [];
    // var renderedThings:Array<RenderedThing> = [];
    // var numbers:Array<Particle> = [];
    var particles:Array<Particle> = [];

    var selectedActor:Null<Actor>;
    var selectedThing:Null<Thing>;

    var gameId:String;

    // DEBUG:
    var wins:Int = 0;

#if debug
    public var devTexts:Array<BitmapText> = [];
#end

    override function create () {
        super.create();

        gameId = (Math.random() + '').split('.')[1];

        entities.push(stepText = makeBitmapText(160, 16, 'Steps: 0'));

        entities.push(char1 = new NumColumn(24, 24, 60, ['hp', 'rad', 'dindex', 'p', 'id'], 10));
        entities.push(char2 = new NumColumn(240, 24, 60, ['hp', 'rad', 'dindex', 'p', 'id'], 10));

        entities.push(genes1 = new GenesDisplay(16, 108, Run.inst.room.actors[0].dna.genes));
        entities.push(genes2 = new GenesDisplay(230, 108, Run.inst.room.actors[1].dna.genes));

#if debug
        for (i in 0...8) {
            final text = makeBitmapText(0, 74 + i * 10, '');
            entities.push(text);
            devTexts.push(text);
            // text.visible = false;
        }

        Debug.renderTimes = [for (i in 0...300) 0.0]; // 5 seconds on 60fps monitors
        Debug.updateTimes = [for (i in 0...300) 0.0]; // ~5 seconds
#end
    }

    override function update (delta:Float) {
#if debug
        final updateStart = Timer.stamp();
#end

        if (Game.keys.justPressed(KeyCode.R)) {
            game.changeScene(new BattleScene());
        }

        if (Game.keys.justPressed(KeyCode.O)) {
            trace(getData());
        }

        if (Game.keys.justPressed(KeyCode.P)) {
            worldActive = !worldActive;
        }

        var steps = 1;
        if (Game.keys.pressed(KeyCode.J)) {
            steps += 256;
        } else if (Game.keys.pressed(KeyCode.H)) {
            steps += 64;
        } else if (Game.keys.pressed(KeyCode.G)) {
            steps += 16;
        } else if (Game.keys.pressed(KeyCode.F)) {
            steps += 4;
        }

        final room = Run.inst.room;

        var roomSpeed = 20;

        if (worldActive) {
            stepCounter += steps;
            while (stepCounter > roomSpeed) {
                room.step(0);
                updateParticles();
                final dead = room.checkDead();
                if (dead > 0) {
                    if (dead == 2) throw 'Both Dead';
                    gameOver();
                    break;
                }
                if (room.checkSkip()) {
                    gameOver();
                    break;
                }

                stepCounter -= roomSpeed;
            }
            // WARN: overflow from too many events?
            handleEvents(room.getEvents());
        // } else {
        //     updateParticles();
        }

        stepText.setText('Steps: ${room.steps}');

        char1.setStringItem('hp', '${room.actors[0].hp}/${room.actors[0].dna.hp}');
        char1.setItem('rad', room.actors[0].dna.rad);
        char1.setItem('dindex', room.actors[0].dnaIndex);
        char1.setStringItem('p', '${room.actors[0].x},${room.actors[0].y},${room.actors[0].facing}');
        char1.setItem('id', room.actors[0].dna.id);
        char2.setStringItem('hp', '${room.actors[1].hp}/${room.actors[1].dna.hp}');
        char2.setItem('rad', room.actors[1].dna.rad);
        char2.setItem('dindex', room.actors[1].dnaIndex);
        char2.setStringItem('p', '${room.actors[1].x},${room.actors[1].y},${room.actors[1].facing}');
        char2.setItem('id', room.actors[1].dna.id);

        genes1.dIndex = room.actors[0].dnaIndex;
        genes2.dIndex = room.actors[1].dnaIndex;

        pulseTime = (pulseTime + delta) % 0.5;
        pulseOn = pulseTime < 0.25;
        shortPulseOn = (pulseTime % 0.25) < 0.125;

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
#end
    }

    override function render (g2:Graphics, clears:Bool) {
#if debug
        final renderStart = Timer.stamp();
#end
        // PERF: only do this on rotation instead of on every frame, preferably
        // rendering to a single image
        g2.begin(true, camera.bgColor);

        // g2.color = Math.floor(alpha * 256) * 0x1000000 + color;
        g2.color = White;

        roomRender(g2, 100, 32, Run.inst.room, particles);

        g2.end();

        super.render(g2, false);

#if debug
        final time = Timer.stamp();
        final renderTime = time - renderStart;
        Debug.renderTimes.push(renderTime);
        Debug.renderTimes.shift();

        Debug.renderFrames.push(time);
        while (true) {
            if (Debug.renderFrames[0] != null && Debug.renderFrames[0] < time - 0.999) {
                Debug.renderFrames.shift();
            } else {
                break;
            }
        }
#end
    }

    function gameOver () {
        worldActive = false;
        timers.addTimer(2.0, () -> {
            // TODO: add a "next" button
            game.changeScene(new BattleResultsScene());
        });
    }

    function handleEvents (events:Array<RoomEvent>) {
        for (e in events) {
            if (e.type == ThingEnd) {
                particles.push({ tile: 176 + e.thingType, x: e.x, y: e.y, dir: e.dir, time: 1 });
            }
            if (e.type == Damage) {
                particles.push({ tile: -1, x: e.x, y: e.y, number: e.amount, time: 2, color: 0xffb4202a });
            }
        }
    }

    function updateParticles () {
        particles = particles.filter(p -> --p.time > 0);
    }

    inline function sendLogs () {
        final req = new haxe.Http('http://localhost:4000');
#if kha_html5
        req.async = true;
#end
        req.setPostData(getData());
        req.setHeader('Content-Type', 'application/json');
        req.onStatus = (num) -> {
            trace('status: ', num);
        };
        req.onError = (msg) -> {
            trace('error', msg);
        };
        req.request(true);
    }

    inline function getData ():String {
        return Json.stringify({
            gameId: gameId,
            seed: Run.inst.seed,
            // commands: world.commands
        });
    }
}
