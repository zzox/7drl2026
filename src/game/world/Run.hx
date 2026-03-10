package game.world;

import core.util.Util;
import game.world.Dna;
import haxe.Json;
import kha.math.Random;

enum abstract CommandType(Int) {
    var TempCommand = 0;
}

typedef Command = {
    var type:CommandType;
    // TODO: turn optional props into union type
    var ?dId:DId;
}

function makeTempCommand (dId:DId):Command {
    return {
        type: TempCommand,
        dId: dId
    }
}

class Run {
    public static var inst:R;

    public function new () {
        inst = new R();
        inst.init();
    }
}
class R {
    public var seed:Int;
    public var rand:Random;
    public var placeRand:Random;
    // public var stats:Stats = newEmptyStats();

    public var world:World;
    public var room:Null<Room>;
    public var nursery:Nursery;
    public var mix:Null<Mix>;
    public var mutation:Null<Mutation>;
    public var sale:Null<Sale>;

    public var day:Int = 0;
    public var money:Int = 100;
    public var wins:Int = 0;
    public var losses:Int = 0;
    public var skips:Int = 0;

    public var commands:Array<{ day:Int, command: Command }> = [];

    public var roster:Array<Dna> = [];
    public var graveyard:Array<Dna> = [];
    public var order:Array<Dna> = [];
    public var defeated:Array<Dna> = [];
    public var skipped:Array<Dna> = [];
    public var forSale:Array<Dna> = [];

    public function new (?startSeed:Int) {
        // final ttt = Timer.stamp();
        // final rand = new kha.math.Random(1000);
        // for (_ in 0...1_000_000) {
        //     final i = rand.GetFloat();
        // }
        // trace(Timer.stamp() - ttt);

        this.seed = startSeed ?? Math.floor(Math.random() * 1234567);
        rand = new kha.math.Random(seed);
        placeRand = new kha.math.Random(1312);
        Dna.curId = 0;
    }

    public function init () {
        final adam = new Dna();
        final steve = new Dna();

        roster = combineDna(adam, steve, 5, 4);

        world = new World();
        order = world.geneCopies;
        makeForSale();
    }

    public function fightNext (fighter:Dna) {
        makeRoom(fighter, order[0]);
        // money -= fightNextMoney();
    }

    public function fightNextMoney () {
        return Std.int(10 + defeated.length * defeated.length);
    }

    public function skipNext () {
        if (money < 0) {
            throw 'No Money';
        }

        final dollars = skipNextMoney();
        skipped.push(order.shift());
        money -= dollars;
        skips++;
    }

    public function skipNextMoney () {
        return Std.int(100 * Math.pow(2, defeated.length));
    }

    public function rewardMoney () {
        final past = defeated.length + skipped.length;
        return Std.int(100 + past * past * 5);
    }

    public function makeRoom (dna1:Dna, dna2:Dna) {
        room = new Room(dna1, dna2);
        // matches++;
    }

    public function handleRoom () {
        if (!room.checkSkip() && room.checkDead() == 0) {
            throw 'No result on room?';
        }

        if (room.actors[0].hp <= 0) {
            roster = roster.filter(r -> r != room.actors[0].dna);
            graveyard.push(room.actors[0].dna);
            losses++;
        }

        if (room.actors[1].hp <= 0) {
            room.actors[0].dna.wins++;
            room.actors[0].dna.hp = Std.int(Math.max(1, room.actors[0].dna.hp - room.actors[0].dna.rad));
            room.actors[0].dna.rad++;
            money += rewardMoney();
            defeated.push(order.shift());
            wins++;
            makeForSale();
        }

        // room = null;
        day++;
    }

    public function makeNursery (dna1:Dna, dna2:Dna) {
        nursery = new Nursery(dna1, dna2);
    }

    public function handleNursery () {
        roster = roster.filter(r -> !nursery.parents.contains(r));
        roster = roster.concat(nursery.children);
        nursery = null;
        day++;
    }

    public function doSale (guy:Dna) {
        sale = new Sale(guy);
    }

    public function doMix (guy:Dna) {
        if (mixMoney(guy) > money) {
            throw 'No money';
        }

        mix = new Mix(guy);
        money -= mixMoney(guy);
    }

    public function doMutate (guy:Dna) {
        if (mutateMoney(guy) > money) {
            throw 'No money';
        }

        mutation = new Mutation(guy);
        money -= mutateMoney(guy);
    }

    public function handleMix () {
        mix.guy.genes = mix.value;
        mix.guy.rad += 1;
        mix = null;
    }

    public function handleMutate () {
        mutation.guy.genes = mutation.value;
        mutation.guy.rad += 3;
        mutation = null;
    }

    public function handleSale () {
        roster = roster.filter(g -> g != sale.guy);
        money += sellMoney(sale.guy);
        sale = null;
    }

    public function sellMoney (guy:Dna):Int {
        final genesMoney = Lambda.fold(guy.genes, (item, res) -> res + genePrices.get(item), 0);
        return Std.int(Math.max(genesMoney - guy.rad * 3, 0));
    }

    public function mixMoney (guy:Dna):Int {
        return Math.floor(Lambda.fold(guy.genes, (item, res) -> res + genePrices.get(item), 0) / 2);
    }

    public function mutateMoney (guy:Dna):Int {
        return Lambda.fold(guy.genes, (item, res) -> res + genePrices.get(item), 0) * 2;
    }

    public function buyMoney () {
        if (forSale.length == 0) {
            throw 'Cant pass';
        }
        return mutateMoney(forSale[0]);
    }

    public function doBuy () {
        if (forSale.length == 0 || mutateMoney(forSale[0]) > money) {
            trace(forSale.length, mutateMoney(forSale[0]));
            throw 'Cant buy';
        }

        roster.push(forSale.shift());
    }

    public function doPass () {
        if (forSale.length == 0) {
            throw 'Cant pass';
        }

        forSale.shift();
    }

    function makeForSale () {
        forSale = combineDna(new Dna(), new Dna(), order[0].generation / 2, 3);
    }

    public function establishRun () {
        order = world.geneCopies.copy();
        world = null;
    }

    public function doCommand (command:Command):Bool {
        if (command.type == TempCommand) {}
        commands.push({ day: day, command: command });
        return true;
    }

    public function randomInt (num:Int):Int {
        return rand.GetUpTo(num - 1);
    }

    public function randomItem <T>(items:Array<T>):T {
        return items[randomInt(items.length)];
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
            // gameId: gameId,
            seed: seed,
            // commands: world.commands
        });
    }
}
