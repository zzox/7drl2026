package game.world;

import core.Types;
import game.data.Stats;
import game.util.Utils.checkEq;
import game.world.Actor;
import game.world.Grid;
import game.world.Thing;
import game.world.WorldEvent;

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

class Room {
    static inline final Width = 8;
    static inline final Height = 8;

    public var grid:Grid<Int>;
    public var things:Array<Thing> = [];
    public var actors:Array<Actor> = [];

    public var lights:Grid<Float>;
    var startGrid:Grid<Int>;

    public var stats:Stats;
    public var events:Array<Event> = [];

    public function new (dna1:Dna, dna2:Dna) {
        grid = makeGrid(Width, Height, 0);
        lights = makeGrid(Width, Height, 1.0);

        grid = mapGI(grid, (x, y, item) -> {
            return Math.random() < 0.1 ? 1 : 0;
        });

        stats = newEmptyStats();

        actors.push(new Actor(dna1, 0));
        actors.push(new Actor(dna2, 1));
    }

    public function step (time:Int) {
        for (a in actors) {}

        if (World.rand.GetFloat() < 1 / 1000) {}

        // if there's issues, recheck collision here

        for (a in actors) {
            a.time--;
            if (a.time > 0) continue;

            if (a.time == 0) {
                if (World.rand.GetFloat() < 0.1) {
                    tryMove(a, East);
                } else if (World.rand.GetFloat() < 0.2) {
                    tryMove(a, South);
                } else if (World.rand.GetFloat() < 0.3) {
                    tryMove(a, West);
                } else if (World.rand.GetFloat() < 0.4) {
                    tryMove(a, North);
                }

                a.time = a.dna.speed;
            }

#if debug
            if (a.time == 0) {
                trace(a.name);
                throw 'Illegal `state`';
            }
#end
        }

        updateLights(time);
    }

    // returns true if there is a collision at this position
    function checkCollision (x:Int, y:Int/*, actor:Actor*/):Bool {
        for (a in actors) {
            if (checkEq(a.x, a.y, x, y)) return true;
        }
        final item = getGridItem(grid, x, y);
        return item == null;
    }

    function tryMove (actor:Actor, dir:RotationDir) {
        if (dir == North && !checkCollision(actor.x, actor.y - 1)) actor.y--;
        if (dir == South && !checkCollision(actor.x, actor.y + 1)) actor.y++;
        if (dir == East && !checkCollision(actor.x + 1, actor.y)) actor.x++;
        if (dir == West && !checkCollision(actor.x - 1, actor.y)) actor.x--;
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

    inline function addEvent (type:EventType, ?actor:Actor, ?amount:Int, ?thing:Thing) {
        events.push({ type: type, actor: actor, amount: amount, thing: thing });
    }
}
