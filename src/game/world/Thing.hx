package game.world;

import game.world.Dna;
import game.world.Grid;

enum ThingType {
    Pierce;
}

typedef Thing = {
    var x:Int;
    var y:Int;
    var type:ThingType;
    var facing:RotationDir;
    // var from:Actor;
    var time:Int;
}

final thingMoves:Map<ThingType, Bool> = [
    Pierce => false
];

function getThingType (gene:Gene):ThingType {
    switch (gene) {
        case Pierce: return Pierce;
        default: throw 'Cant get thing';
    }
}
