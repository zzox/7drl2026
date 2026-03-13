package game.scenes;

import core.Game;
import core.Types;
import core.gameobjects.BitmapText;
import core.gameobjects.Sprite;
import game.ui.BarEl;
import game.ui.DamageNumber;
import game.ui.GeneSelectWindow.GuyIcon;
import game.ui.GenesDisplay;
import game.ui.NumColumn;
import game.ui.RoomRender;
import game.ui.UiElement;
import game.ui.UiText;
import game.util.Debug;
import game.util.Player;
import game.world.Actor;
import game.world.Dna;
import game.world.Room.RoomEvent;
import game.world.Room;
import game.world.Run;
import game.world.Thing;
import haxe.Timer;
import kha.Assets;
import kha.graphics2.Graphics;
import kha.input.KeyCode;

class BattleScene extends ButtonScene {
    public static final White:Int = 256 * 0x1000000 + 0xffffffff;

    static var pulseTime:Float = 0.0;
    public static var pulseOn:Bool = true;
    public static var shortPulseOn:Bool = true;

    // var uiScene:UiScene;
    // var logs:Logs;
    var worldActive:Bool = true;
    var tilePosAt:IntVec2 = new IntVec2(0, 0);

    var stepCounter:Int = 0;
    var roomSpeed:Int = 20;

#if debug
    var stepText:BitmapText;
#end
    // var winsText:BitmapText;
    var guy1:GuyIcon;
    var guy2:GuyIcon;
    var char1:NumColumn;
    var char2:NumColumn;
    var genes1:GenesDisplay;
    var genes2:GenesDisplay;
    var hp1:BarEl;
    var hp2:BarEl;
    var damageGuy1:GuyIcon;
    var damageGuy2:GuyIcon;
    var damageType:Sprite;
    var damageNumber:BitmapText;

    var speed1:UiElement;
    var speed2:UiElement;
    var speed3:UiElement;
    var speed4:UiElement;
    var auto:UiElement;

    // var renderedActors:Array<RenderedActor> = [];
    // var renderedThings:Array<RenderedThing> = [];
    // var numbers:Array<Particle> = [];
    var particles:Array<Particle> = [];

    var selectedActor:Null<Actor>;
    var selectedThing:Null<Thing>;

    // HACK;
    var speed:Int = 1;

#if debug
    public var devTexts:Array<BitmapText> = [];
#end

    override function create () {
        super.create();

        final p1 = Run.inst.room.actors[0];
        final p2 = Run.inst.room.actors[1];

#if debug
        entities.push(stepText = makeBitmapText(200, 16, 'Steps: 0'));
#end

        entities.push(guy1 = new GuyIcon(16, 72));
        entities.push(guy2 = new GuyIcon(240, 24));

        final name1 = p1.dna.name.split(' ');
        final name2 = p2.dna.name.split(' ');

        entities.push(makeBitmapText(32, 66, name1[0]));
        entities.push(makeBitmapText(32, 76, name1[1]));

        entities.push(makeBitmapText(256, 22, name2[0]));
        entities.push(makeBitmapText(256, 32, name2[1]));

        guy1.dna = p1.dna;
        guy2.dna = p2.dna;

        entities.push(damageGuy1 = new GuyIcon(132, 160));
        entities.push(damageGuy2 = new GuyIcon(164, 160));
        entities.push(damageType = new Sprite(148, 160, Assets.images.ui, 16, 16));
        entities.push(damageNumber = makeBitmapText(192, 160));

        damageGuy1.frames = 90;
        damageGuy2.frames = 270;
        damageType.angle = 90;
        damageNumber.color = 0xb4202a;

        damageGuy1.visible = false;
        damageGuy2.visible = false;
        damageType.visible = false;
        damageNumber.visible = false;

// #if debug
//         entities.push(char1 = new NumColumn(24, 24, 60, ['hp', 'rad', 'dindex', 'p', 'id'], 10));
//         entities.push(char2 = new NumColumn(240, 24, 60, ['hp', 'rad', 'dindex', 'p', 'id'], 10));
// #else
        entities.push(char1 = new NumColumn(20, 88, 60, ['hp'], 10));
        entities.push(char2 = new NumColumn(240, 44, 60, ['hp'], 10));
// #end

        entities.push(genes1 = new GenesDisplay(20, 116, p1.dna.genes));
        entities.push(genes2 = new GenesDisplay(240, 72, p2.dna.genes));

        speed1 = new UiElement(100, 16, 16, 16, 4, 4, 12, 12, 16, 16, 48, Assets.images.ui, () -> { setSpeed(0); });
        speed2 = new UiElement(116, 16, 16, 16, 4, 4, 12, 12, 16, 16, 52, Assets.images.ui, () -> { setSpeed(1); });
        speed3 = new UiElement(132, 16, 16, 16, 4, 4, 12, 12, 16, 16, 56, Assets.images.ui, () -> { setSpeed(2); });
        speed4 = new UiElement(148, 16, 16, 16, 4, 4, 12, 12, 16, 16, 60, Assets.images.ui, () -> { setSpeed(3); });
        auto = new UiElement(192, 16, 32, 16, 4, 4, 30, 14, 32, 16, 112, Assets.images.ui, () -> { setSpeed(-1); });

        entities.push(speed1);
        entities.push(speed2);
        entities.push(speed3);
        entities.push(speed4);
        entities.push(auto);

        buttons.push(speed1);
        buttons.push(speed2);
        buttons.push(speed3);
        buttons.push(speed4);
        buttons.push(auto);

        entities.push(new UiElement(20, 102, 16, 16, 2, 2, 14, 14, 64, 8, 84, Assets.images.ui));
        entities.push(new UiElement(240, 58, 16, 16, 2, 2, 14, 14, 64, 8, 84, Assets.images.ui));

        entities.push(hp1 = new BarEl(22, 104, 16, 16, 1, 1, 15, 15, 60, 4, [{min: 0.0, index: 86}, {min: 0.2, index: 85}], p1.dna.hp, p1.dna.hp, [[0.05, 0.1], [-1.0, 0.05]]));
        entities.push(hp2 = new BarEl(242, 60, 16, 16, 1, 1, 15, 15, 60, 4, [{min: 0.0, index: 86}, {min: 0.2, index: 85}], p2.dna.hp, p2.dna.hp, [[0.05, 0.1], [-1.0, 0.05]]));

        Game.bgScene.set(0);

        setSpeed(Run.speed);

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

        if (Game.keys.justPressed(KeyCode.P)) {
            worldActive = !worldActive;
        }

        var s = 1;
#if debug
        if (Game.keys.pressed(KeyCode.J)) {
            s += 256;
        } else if (Game.keys.pressed(KeyCode.H)) {
            s += 64;
        } else if (Game.keys.pressed(KeyCode.G)) {
            s += 16;
        } else if (Game.keys.pressed(KeyCode.F)) {
            s += 4;
        }
#end

        final room = Run.inst.room;

        if (speed == -1) {
            if (room.steps > 2000) {
                roomSpeed = 1;
                s = 8;
            } else if (room.steps > 1500) {
                roomSpeed = 1;
                s = 4;
            }  else if (room.steps > 750) {
                roomSpeed = 1;
                s = 2;
            } else if (room.steps < 48 || room.steps - room.lastHit == 0) {
                roomSpeed = 5;
                s = 1;
            } else if (room.steps < 96 || room.steps - room.lastHit < 48) {
                roomSpeed = 3;
                s = 1;
            } else if (room.steps - room.lastHit < 96) {
                roomSpeed = 1;
                s = 2;
            } else if (room.steps - room.lastHit < 192) {
                roomSpeed = 1;
                s = 4;
            } else {
                roomSpeed = 1;
                s = 8;
            }
        }

        if (worldActive) {
            stepCounter += s;
            while (stepCounter > roomSpeed) {
                room.step(0);
                updateParticles();
                final dead = room.checkDead();
                if (dead > 0) {
                    // if (dead == 2) throw 'Both Dead';
                    gameOver(true);
                    break;
                }
                if (room.checkSkip()) {
                    gameOver(false);
                    break;
                }

                stepCounter -= roomSpeed;
            }
            // WARN: overflow from too many events?
            handleEvents(room.getEvents());
        // } else {
        //     updateParticles();
        } else {
            while (stepCounter > roomSpeed) {
                updateParticles();
                stepCounter -= roomSpeed;
            }
        }

#if debug
        stepText.setText('Steps: ${room.steps}');
#end

        hp1.value = Std.int(Math.max(room.actors[0].hp, 0));
        hp2.value = Std.int(Math.max(room.actors[1].hp, 0));

        char1.setStringItem('hp', '${Math.max(room.actors[0].hp, 0)}/${room.actors[0].dna.hp}');
        // char1.setItem('rad', room.actors[0].dna.rad);
        // char1.setItem('dindex', room.actors[0].dnaIndex);
        // char1.setStringItem('p', '${room.actors[0].x},${room.actors[0].y},${room.actors[0].facing}');
        // char1.setItem('id', room.actors[0].dna.id);
        char2.setStringItem('hp', '${Math.max(room.actors[1].hp, 0)}/${room.actors[1].dna.hp}');
        // char2.setItem('rad', room.actors[1].dna.rad);
        // char2.setItem('dindex', room.actors[1].dnaIndex);
        // char2.setStringItem('p', '${room.actors[1].x},${room.actors[1].y},${room.actors[1].facing}');
        // char2.setItem('id', room.actors[1].dna.id);

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
        g2.begin(false);

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

    function gameOver (death:Bool) {
        worldActive = false;
        timers.addTimer(2.0, () -> {
            // TODO: add a "next" button
            game.changeScene(new BattleResultsScene());
        });

        if (death) {
            Player.playCry();
        } else {
            Player.playSound(Assets.sounds.sons_noise2, 0.1);
        }
    }

    function handleEvents (events:Array<RoomEvent>) {
        for (e in events) {
            if (e.type == ThingEnd) {
                particles.push({ tile: 176 + e.thingType, x: e.x, y: e.y, dir: e.dir, time: 1 });
            }
            if (e.type == Damage && e.amount != 0) {
                particles.push({ tile: -1, x: e.x, y: e.y, number: e.amount, time: 2, color: 0xffb4202a });
                showDamage(e.actor.dna, e.thingType, e.amount);
                if (speed >= 2) {
                    Player.playSound(Assets.sounds.sons_fx_fast3, 0.05);
                } else {
                    Player.playSound(Assets.sounds.sons_noise3, 0.1);
                }
            }
            if (e.type == Gene && e.gene != None && speed < 2) {
                Player.playSound(Assets.sounds.sons_fx_bonus3, 0.015);
            }
            if (e.type == Heart) {
                particles.push({ tile: 175, x: e.x, y: e.y, dir: North, time: 1 });
            }
        }
    }

    function updateParticles () {
        particles = particles.filter(p -> --p.time > 0);
    }

    function showDamage (dna:Dna, thingType:ThingType, amount:Int) {
        final otherGuy = if (Run.inst.room.actors[0].dna.id == dna.id) {
            Run.inst.room.actors[1].dna;
        } else {
            Run.inst.room.actors[0].dna;
        }

        damageGuy1.dna = otherGuy;
        damageGuy2.dna = dna;
        damageNumber.setText(amount + '');
        damageNumber.x = 192 - Math.floor(damageNumber.textWidth / 2);
        damageType.tileIndex = 160 + thingType;

        damageGuy1.visible = true;
        damageGuy2.visible = true;
        damageNumber.visible = true;
        damageType.visible = true;
    }

    function setSpeed (speed:Int) {
        speed1.disabled = false;
        speed2.disabled = false;
        speed3.disabled = false;
        speed4.disabled = false;
        auto.disabled = false;
        this.speed = speed;

        if (speed == -1) {
            auto.disabled = true;
            roomSpeed = 1;
        } else if (speed == 0) {
            speed1.disabled = true;
            roomSpeed = 20;
        } else if (speed == 1) {
            speed2.disabled = true;
            roomSpeed = 10;
        } else if (speed == 2) {
            speed3.disabled = true;
            roomSpeed = 5;
        } else if (speed == 3) {
            speed4.disabled = true;
            roomSpeed = 1;
        }

        Run.speed = speed;
    }
}
