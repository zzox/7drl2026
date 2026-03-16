package game.world;

import core.util.Util;
import game.world.Dna;
import haxe.Json;
import kha.math.Random;

#if is_ng
import Keys;
import io.newgrounds.NG;
import io.newgrounds.crypto.Cipher;
#end

#if is_ng
function unlockMedal (medalNum:Int) {
    final medal = NG.core.medals.get(medalNum);
    if (medal != null && !medal.unlocked) {
        medal.sendUnlock();
    }
}
// function sendScore (scoreBoard:Int, score:Int, force:Bool = false) {
function sendScore (scoreBoard:Int, score:Int) {
    final board = NG.core.scoreBoards.get(scoreBoard);
    trace(board, board.scores);
    // if (board != null && (force || board.scores == null || board.scores[0].value > score)) {
    //     board.postScore(score);
    // }
    if (board != null) {
        board.postScore(score);
    }
}
#end

function checkRounds (round:Int) {
#if is_ng
    if (round == 4) {
        unlockMedal(medals[0]);
    } else if (round == 8) {
        unlockMedal(medals[1]);
    } else if (round == 12) {
        unlockMedal(medals[2]);
    } else if (round == 16) {
        unlockMedal(medals[3]);
    }
#end
}

enum abstract CommandType(Int) {
    var Fight = 0;
    var SkipFight = 1;
    var Sync = 2;
    var SellGuy = 3;
    var MixGuy = 4;
    var MutateGuy = 5;
    var ShopBuy = 6;
    var ShopPass = 7;
}

typedef Command = {
    var type:CommandType;
    var ?dId:DId;
    var ?dId1:DId;
    var ?dId2:DId;
}

function makeFightCommand (dId:DId):Command {
    return {
        type: Fight,
        dId: dId
    }
}
function makeSkipFightCommand ():Command {
    return {
        type: SkipFight
    }
}

function makeSyncCommand (dId1:DId, dId2:DId):Command {
    return {
        type: Sync,
        dId1: dId1,
        dId2: dId2
    }
}

function makeSellGuyCommand (dId:DId):Command {
    return {
        type: SellGuy,
        dId: dId
    }
}
function makeMixGuyCommand (dId:DId):Command {
    return {
        type: MixGuy,
        dId: dId
    }
}
function makeMutateGuyCommand (dId:DId):Command {
    return {
        type: MutateGuy,
        dId: dId
    }
}

function makeShopBuyCommand ():Command {
    return {
        type: ShopBuy
    }
}
function makeShopPassCommand ():Command {
    return {
        type: ShopPass
    }
}

class Run {
    public static final Generations:Int = 15; // will fight 1 + Generations since we make one at the start
    public static var inst:R;

    public function new (?seed:Int) {
        inst = new R(seed);
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
    public var matches:Int = 0;
    public var money:Int = 100;
    public var wins:Int = 0;
    public var losses:Int = 0;
    public var skips:Int = 0;
    public var offspring:Int = 0;
    public var abandoned:Int = 0;

    public var commands:Array<{ day:Int, command: Command }> = [];

    public var roster:Array<Dna> = [];
    public var graveyard:Array<Dna> = [];
    public var order:Array<Array<Dna>> = [];
    public var defeated:Array<Dna> = [];
    public var skipped:Array<Dna> = [];
    public var forSale:Array<Dna> = [];

    public var justAdded:Int = 0;

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

        trace(seed);
    }

    public function init () {
        final adam = new Dna();
        final steve = new Dna();

        roster = combineDna(adam, steve, 5, 4);

        world = new World();
        order = world.geneCopies;
        // trace(order);
        makeForSale();
    }

    function fightNext (fighter:Dna) {
        makeRoom(fighter, getNextInOrder());
        // money -= fightNextMoney();
    }

    public function fightNextMoney () {
        return Std.int(10 + defeated.length * defeated.length);
    }

    function skipNext () {
        if (money < 0) {
            throw 'No Money';
        }

        final dollars = skipNextMoney();
        skipped.push(shiftNextInOrder());
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

    function makeRoom (dna1:Dna, dna2:Dna) {
        room = new Room(dna1, dna2);
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

            // TEST:
            final item = getNextInOrder();
            defeated.push(shiftNextInOrder());

            // trace('should be true', item == defeated[defeated.length - 1]);

            wins++;
            if (order.length > 0) {
                makeForSale();
            }

            checkRounds(defeated.length + skipped.length);
        }

        day++;
        justAdded = 0;
        matches++;
    }

    function makeNursery (dna1:Dna, dna2:Dna) {
        nursery = new Nursery(dna1, dna2);
    }

    public function handleNursery () {
        roster = roster.filter(r -> !nursery.parents.contains(r));
        roster = roster.concat(nursery.children);
        abandoned += 2;
        offspring += nursery.children.length;
        justAdded = nursery.children.length;
        nursery = null;
        day++;
    }

    function doSale (guy:Dna) {
        sale = new Sale(guy);
    }

    function doMix (guy:Dna) {
        if (mixMoney(guy) > money) {
            throw 'No money';
        }

        mix = new Mix(guy);
        money -= mixMoney(guy);
    }

    function doMutate (guy:Dna) {
        if (mutateMoney(guy) > money) {
            throw 'No money';
        }

        mutation = new Mutation(guy);
        money -= mutateMoney(guy);
    }

    public function handleMix () {
        mix.guy.genes = mix.value;
        mix.guy.rad += 1;
        checkAttitudes(mix.guy);
        justAdded = 0;
        mix = null;
    }

    public function handleMutate () {
        mutation.guy.genes = mutation.value;
        mutation.guy.rad += 3;
        justAdded = 0;
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

    function doBuy () {
        if (forSale.length == 0 || buyMoney() > money) {
            trace(forSale.length, buyMoney());
            throw 'Cant buy';
        }

        money -= buyMoney();
        roster.push(forSale.shift());
        justAdded = 1;
    }

    function doPass () {
        if (forSale.length == 0) {
            throw 'Cant pass';
        }

        forSale.shift();
    }

    function makeForSale () {
        forSale = combineDna(new Dna(), new Dna(), order[0][0].generation / 2, 3);
    }

    public function doCommand (command:Command, sim:Bool = false):Bool {
        if (command.type == Fight) {
            // makeRoom(command.dId)
            fightNext(getFromRoster(command.dId));
        } else if (command.type == SkipFight) {
            skipNext();
        } else if (command.type == Sync) {
            makeNursery(getFromRoster(command.dId1), getFromRoster(command.dId2));
        } else if (command.type == SellGuy) {
            doSale(getFromRoster(command.dId));
        } else if (command.type == MixGuy) {
            doMix(getFromRoster(command.dId));
        } else if (command.type == MutateGuy) {
            trace(command, getFromRoster(command.dId));
            doMutate(getFromRoster(command.dId));
        } else if (command.type == ShopBuy) {
            doBuy();
        } else if (command.type == ShopPass) {
            doPass();
        } else {
            throw 'Unhandled command type';
        }

        if (sim) {
            if (command.type == Fight) {
                while (room.checkDead() == 0 && !room.checkSkip()) {
                    room.step(0);
                }
                handleRoom();
            } else if (command.type == SkipFight) {
            } else if (command.type == Sync) {
                handleNursery();
            } else if (command.type == SellGuy) {
                handleSale();
            } else if (command.type == MixGuy) {
                handleMix();
            } else if (command.type == MutateGuy) {
                handleMutate();
            } else if (command.type == ShopBuy) {
            } else if (command.type == ShopPass) {
            } else {
                throw 'Unhandled command type -- sim';
            }
        }

        commands.push({ day: day, command: command });
        return true;
    }

    public function getNextInOrder () {
        return order[0][matches % order[0].length];
    }

    // gets the one we are facing next, then gets rid of the whole order array at [0];
    function shiftNextInOrder ():Dna {
        final item = order[0].splice(matches % order[0].length, 1)[0];
        order.shift();
        return item;
    }

    function getFromRoster (dId:DId):Dna {
        return roster.filter(i -> i.id == dId)[0];
    }

    public function randomInt (num:Int):Int {
        return rand.GetUpTo(num - 1);
    }

    public function randomItem <T>(items:Array<T>):T {
        return items[randomInt(items.length)];
    }

    public function submitRun () {
#if is_ng
        sendScore(scores[0], skipped.length + defeated.length);
        sendScore(scores[1], money);
#end
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

    public inline function getData ():String {
        return Json.stringify({
            commands: commands,
            day: day,
            seed: seed,
            sons: roster.length
        });
    }
}
