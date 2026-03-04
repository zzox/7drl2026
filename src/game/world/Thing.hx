package game.world;

import game.world.Dna;
import game.world.Grid;

enum abstract ThingType(Int) to Int {
    var TPierce = 0;
    var TPunch = 1;
    var TSpit = 2;
}

typedef Thing = {
    var x:Int;
    var y:Int;
    var type:ThingType;
    var facing:RotationDir;
    // var from:Actor;
    var time:Int;
}

final thingData:Map<ThingType, { moves:Bool, damage:Int }> = [
    TPierce => { moves: false, damage: 0, },
    TPunch => { moves: false, damage: 10 },
    TSpit => { moves: true, damage: 3 }
];

function getThingType (gene:Gene):ThingType {
    switch (gene) {
        case Pierce: return TPierce;
        case Punch: return TPunch;
        case Spit: return TSpit;
        default: throw 'Cant get thing';
    }
}
