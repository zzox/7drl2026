package game.world;

import core.Types;
import core.util.Util;
import game.data.Stats;
import game.util.Utils;
import game.world.Actor;
import game.world.Dna.Gene;
import game.world.Grid;
import game.world.Thing;

function indexDiff (x:Int, y:Int, rand:() -> Float):Int {
    if (rand() * 8.0 < 1.0) return 1;
    if (rand() * 16.0 < 1.0) return 2;
    if (rand() * 32.0 < 1.0) return 3;
    return 0;
}
function dirDiff (x:Int, y:Int, rand:() -> Float):RotationDir {
    if (rand() < 0.25) return East;
    if (rand() < 0.5) return West;
    if (rand() < 0.75) return North;
    return South;
}

final dirs = [North, South, East, West];

enum RoomEventType {
    Gene;
    Damage;
    ThingEnd;
    Heart;
}

typedef RoomEvent = {
    var type:RoomEventType;
    // var actor;
    var ?amount:Int;
    var ?x:Int;
    var ?y:Int;
    var ?thingType:ThingType;
    var ?dir:RotationDir;
    var ?gene:Gene;
}

class Room {
    static inline final Width = 8;
    static inline final Height = 8;

    public var steps:Int = 0;
    public var grid:Grid<Int>;
    public var things:Array<Thing> = [];
    public var actors:Array<Actor> = [];

    public var lights:Grid<Float>;
    var startGrid:Grid<Int>;

    public var stats:Stats;

    var events:Array<RoomEvent> = [];

    public function new (dna1:Dna, dna2:Dna) {
        grid = makeGrid(Width, Height, 0);
        lights = makeGrid(Width, Height, 1.0);

        grid = mapGI(grid, (x, y, item) -> {
            return Run.inst.placeRand.GetFloat() < 0.1 ? 1 : 0;
        });

        stats = newEmptyStats();

        actors.push(new Actor(dna1, 0));
        actors.push(new Actor(dna2, 1));
    }

    public function step (time:Int):Bool {
        for (a in actors) {}

        steps++;

        if (Run.inst.rand.GetFloat() < 1 / 1000) {}

        // if there's issues, recheck collision here

        var moved = false;
        for (a in actors) {
            a.dnaIndex = (a.dnaIndex + 1) % a.dna.genes.length;
            actorDo(a.dna.genes[a.dnaIndex], a, getEnemy(a));
        }

        for (t in things) {
            final data = thingData.get(t.type);
            if (t.alive && data.moves) {
                t.x = getLaunchX(t.x, t.facing);
                t.y = getLaunchY(t.y, t.facing);
            }
        }

        // check collision amongst things
        for (t in things) {
            for (tt in things) {
                if (t != tt && checkEq(t.x, t.y, tt.x, tt.y)) {
                    if (t.type == TPunch && tt.type == TSpit) {
                        tt.alive = false;
                    } else if (tt.type == TPunch && t.type == TSpit) {
                        t.alive = false;
                    } else if (t.type == TDeflect) {
                        trace('deflecting');
                        tt.facing = calculateFacing(tt.facing, 2);
                        getLaunchX(tt.x, tt.facing);
                        getLaunchY(tt.y, tt.facing);
                    } else if (tt.type == TDeflect) {
                        t.facing = calculateFacing(t.facing, 2);
                        getLaunchX(t.x, t.facing);
                        getLaunchY(t.y, t.facing);
                    }
                }
            }
        }

        // check things
        // we set things to -1 if there's a collision and the thing needs to stop
        for (t in things) {
            final data = thingData.get(t.type);
            for (a in actors) {
                if (t.alive && checkEq(t.x, t.y, a.x, a.y)) {
                    var damage = data.damage;
                    // pierces to incremental damage
                    if (t.type == TPierce) {
                        a.pierces++;
                        damage = a.pierces;
                    }
                    a.hp -= damage;

                    if (t.type == THeart) {
                        a.skipNext = true;
                    }

                    // a punch will push someone back
                    if (t.type == TPunch) {
                        tryPush(t, a);
                    }

                    addEvent(Damage, damage, a.x, a.y);
                    t.alive = false;
                }
            }

            // out of bounds check
            if (t.x < 0 || t.x >= grid.width || t.y < 0 || t.y >= grid.height) {
                t.alive = false;
            }

            if (t.alive && !data.moves) {
                t.alive = false;
            }
        }

        things = things.filter(t -> {
            if (t.alive) {
                return true;
            }

            addEvent(ThingEnd, null, t.x, t.y, t.type, t.facing);
            return false;
        });

        // updateLights(time);

        return moved;
    }

    public function checkDead ():Int {
        var over = 0;
        for (a in actors) {
            if (a.hp <= 0) {
                over++;
            }
        }
        return over;
    }

    // returns true if we did too many steps or too many steps with no damage
    public function checkSkip ():Bool {
        final damage = Lambda.fold(actors, (a, res) -> (a.dna.hp - a.hp) + res, 0);
        return steps == 1000 || (steps == 500 && damage == 0);
    }

    function actorDo (gene:Gene, fromActor:Actor, toActor:Actor) {
        addEvent(Gene, null, null, null, null, null, gene);
        if (gene == None) return;

        if (fromActor.skipNext) {
            fromActor.skipNext = false;
            addEvent(Heart, null, fromActor.x, fromActor.y);
            return;
        }

        if (gene == Forward) tryForward(fromActor);
        if (gene == Back) tryBack(fromActor);
        if (gene == TurnTo) tryTurnTo(fromActor, toActor);
        if (gene == TurnAway) tryTurnAway(fromActor, toActor);
        if (gene == Pierce) launchProj(fromActor, Pierce);
        if (gene == Punch) launchProj(fromActor, Punch);
        if (gene == Spit) launchProj(fromActor, Spit);
        if (gene == Heart) launchProj(fromActor, Heart);
        if (gene == Deflect) launchDeflect(fromActor);
    }

    function launchDeflect (fromActor:Actor) {
        for (dir in dirs) {
            final thing = {
                type: TDeflect,
                x: getLaunchX(fromActor.x, dir),
                y: getLaunchY(fromActor.y, dir),
                facing: dir,
                alive: true
            }
            things.push(thing);
        }
    }

    function launchProj (fromActor:Actor, type:Gene) {
        final thingType = getThingType(type);
        final moves = thingData.get(thingType).moves;

        final thing = {
            type: thingType,
            x: moves ? fromActor.x : getLaunchX(fromActor.x, fromActor.facing),
            y: moves ? fromActor.y : getLaunchY(fromActor.y, fromActor.facing),
            facing: fromActor.facing,
            alive: true
        }
        things.push(thing);
    }

    inline function tryTurnTo (fromActor:Actor, toActor:Actor) {
        var angle = angleFromPoints(toActor.x, toActor.y, fromActor.x, fromActor.y) - getFacingAngle(fromActor.facing);

        // DEBUG:
        // final angle1 = angle;
        // final before = fromActor.facing;

        if (angle < -180) {
            angle += 360;
        }

        if (angle > 180) {
            angle -= 360;
        }

        if (angle < -45) {
            fromActor.facing = figureRotationMath(fromActor.facing - 1);
        } else if (angle > 45) {
            fromActor.facing = figureRotationMath(fromActor.facing + 1);
        }
        // trace(fromActor.x, fromActor.y, toActor.x, toActor.y, angle1, angle, before, fromActor.facing);
    }

    inline function tryTurnAway (fromActor:Actor, toActor:Actor) {
        var angle = angleFromPoints(toActor.x, toActor.y, fromActor.x, fromActor.y) - getFacingAngle(fromActor.facing);

        if (angle < -180) {
            angle += 360;
        }

        if (angle > 180) {
            angle -= 360;
        }

        if (angle > 135 || angle < -135) {
        } else if (angle < 0) {
            fromActor.facing = figureRotationMath(fromActor.facing + 1);
        } else if (angle >= 0) {
            fromActor.facing = figureRotationMath(fromActor.facing - 1);
        }
    }

    inline function tryPush (thing:Thing, actor:Actor) {
        if (thing.facing == North && !checkCollision(actor.x, actor.y - 1)) actor.y--;
        if (thing.facing == South && !checkCollision(actor.x, actor.y + 1)) actor.y++;
        if (thing.facing == East && !checkCollision(actor.x + 1, actor.y)) actor.x++;
        if (thing.facing == West && !checkCollision(actor.x - 1, actor.y)) actor.x--;
    }

    inline function tryForward (actor:Actor) {
        if (actor.facing == North && !checkCollision(actor.x, actor.y - 1)) actor.y--;
        if (actor.facing == South && !checkCollision(actor.x, actor.y + 1)) actor.y++;
        if (actor.facing == East && !checkCollision(actor.x + 1, actor.y)) actor.x++;
        if (actor.facing == West && !checkCollision(actor.x - 1, actor.y)) actor.x--;
    }

    inline function tryBack (actor:Actor) {
        if (actor.facing == North && !checkCollision(actor.x, actor.y + 1)) actor.y++;
        if (actor.facing == South && !checkCollision(actor.x, actor.y - 1)) actor.y--;
        if (actor.facing == East && !checkCollision(actor.x - 1, actor.y)) actor.x--;
        if (actor.facing == West && !checkCollision(actor.x + 1, actor.y)) actor.x++;
    }

    // returns true if there is a collision at this position
    function checkCollision (x:Int, y:Int/*, actor:Actor*/):Bool {
        for (a in actors) {
            if (checkEq(a.x, a.y, x, y)) return true;
        }
        final item = getGridItem(grid, x, y);
        return item == null;
    }

    // TODO: move to grid
    function getNeighborItems (grid:Grid<Int>, x:Int, y:Int):Array<IntVec2> {
        final items = [];

        final north = getGridItem(grid, x, y - 1);
        final south = getGridItem(grid, x, y + 1);
        final east = getGridItem(grid, x + 1, y);
        final west = getGridItem(grid, x - 1, y);

        if (north != null) items.push(new IntVec2(x, y - 1));
        if (south != null) items.push(new IntVec2(x, y + 1));
        if (east != null) items.push(new IntVec2(x + 1, y));
        if (west != null) items.push(new IntVec2(x - 1, y));

        return items;
    }

    inline function getTilesFromDiffs (lx:Int, ly:Int, diffs:Array<IntVec2>):Array<Int> {
        final tilesSeen = [lx + ly * grid.width];

        for (i in 0...diffs.length) {
            // final angle = r / numRlys * 360;
            // final dist = velocityFromAngle(angle, seeDistance);

            var dx:Int = Std.int(Math.abs(lx - (lx + diffs[i].x)));
            var dy:Int = Std.int(Math.abs(ly - (ly + diffs[i].y)));
            var x:Int = lx;
            var y:Int = ly;
            // don't use the 1 increment here
            // var n:Int = 1 + dx + dy;
            var n:Int = dx + dy;
            final xInc:Int = diffs[i].x > 0 ? 1 : -1;
            final yInc:Int = diffs[i].y > 0 ? 1 : -1;
            var error:Int = dx - dy;
            dx *= 2;
            dy *= 2;

            var start = true;
            while (n > 0) {
                // final gridItem = getGridItem(world.grid, x, y);
                final collided = checkCollision(x, y/*, null*/);

                if (error > 0) {
                    x += xInc;
                    error -= dy;
                } else {
                    y += yInc;
                    error += dx;
                }

                if (x < 0 || x >= lights.width || y < 0 || y >= lights.height) {
                    break;
                }

                // stop line when going off the edge of the map or an object,
                // object is inclusive.
                if (collided && !start) break; {
                    start = false;
                }

                // hack using an int so we don't need to allocate new IntVec2's
                if (!tilesSeen.contains(x + y * grid.width)) tilesSeen.push(x + y * grid.width);

                n--;
            }
        }

        return tilesSeen;
    }

    final diffs = [new IntVec2(-2, -2), new IntVec2(-1, -3), new IntVec2(0, -3), new IntVec2(1, -3), new IntVec2(2, -2), new IntVec2(3, -1), new IntVec2(3, 0), new IntVec2(3, 1), new IntVec2(2, 2), new IntVec2(1, 3), new IntVec2(0, 3), new IntVec2(-1, 3), new IntVec2(-2, 2), new IntVec2(-3, 1), new IntVec2(-3, 0), new IntVec2(-3, -1)];
    final diffs2 = [new IntVec2(-3, -2), new IntVec2(-2, -3), new IntVec2(-1, -4), new IntVec2(0, -4), new IntVec2(1, -4), new IntVec2(2, -3), new IntVec2(3, -2), new IntVec2(4, -1), new IntVec2(4, 0), new IntVec2(4, 1), new IntVec2(3, 2), new IntVec2(2, 3), new IntVec2(1, 4), new IntVec2(0, 4), new IntVec2(-1, 4), new IntVec2(-2, 3), new IntVec2(-3, 2), new IntVec2(-4, 1), new IntVec2(-4, 0), new IntVec2(-4, -1)];
    // PERF:
    inline function updateLights (time:Int) {
        function hours (num:Int) {
            return num * 60;
        }

        final light = if (time < hours(5) || time > hours(21)) {
            0.0;
        } else if (time < hours(7)) {
            (time - hours(5)) / hours(2);
        } else if (time > hours(19)) {
            (1.0 - (time - hours(19)) / hours(2));
        } else {
            1.0;
        }

        lights = mapGI(lights, (x, y, item) -> {
            return light;
        });

        // final distance1 = getDistanceDiffs(5);
        // final distance2 = getDistanceDiffs(7);

        // for (a in actors) {
        //     final ax = a.getX();
        //     final ay = a.getY();

        final lightItems = things.filter(t -> true);
        // final lightItems = things.filter(t -> isLight(t));

        for (li in lightItems) {
            final ax = li.x;
            final ay = li.y;

            final tilesSeen = getTilesFromDiffs(ax, ay, diffs);
            for (t in tilesSeen) {
                final gi = lights.items[t];
                lights.items[t] = Math.min(gi + 0.2, 1.0);
            }

            final tilesSeen2 = getTilesFromDiffs(ax, ay, diffs2);
            for (t in tilesSeen2) {
                final gi = lights.items[t];
                lights.items[t] = Math.min(gi + 0.2, 1.0);
            }
        }
    }

    inline function getEnemy (actor:Actor) {
        if (actor == actors[0]) {
            return actors[1];
        }
        return actors[0];
    }

    inline function addEvent (type:RoomEventType, /* ?actor:Actor, */ ?amount:Int, ?x:Int, ?y:Int, ?thingType:ThingType, ?dir:RotationDir, ?gene:Gene) {
#if !harness
        events.push({ type: type, /*actor: actor,*/ amount: amount, x: x, y: y, thingType: thingType, dir: dir });
#end
    }

    public function getEvents () {
        final e = events;
        events = [];
        return e;
    }
}
