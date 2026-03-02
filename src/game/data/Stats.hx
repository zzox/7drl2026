package game.data;

typedef Stats = {
    var temp:Int;
}

function newEmptyStats ():Stats {
    return {
        temp: 0
    }
}

function addStats (stats1:Stats, stats2:Stats):Stats {
    return {
        temp: stats1.temp + stats2.temp
    }
}
