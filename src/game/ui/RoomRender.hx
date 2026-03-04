package game.ui;

import core.util.Util;
import game.util.Utils;
import game.world.Grid;
import game.world.Room;
import kha.Assets;
import kha.graphics2.Graphics;

typedef Particle = {
  var tile:Int;
  var time:Int;
  var x:Int;
  var y:Int;
  var ?dir:RotationDir;
//   var ?collTime:Int;
  var ?number:Int;
  var ?color:Int;
}

function roomRender (g2:Graphics, posX:Int, posY:Int, room:Room, particles:Array<Particle>) {
    final sizeX = 16;
    final sizeY = 16;

    final image = Assets.images.ui;
    final cols = Std.int(image.width / sizeX);
    forEachGI(room.grid, (x, y, item) -> {
        // if (items[i].item == -1) continue;

        final tileIndex = item == 0 ? 97 : 98;

        // g2.color = 0xff * 0x1000000 + getLightColor(getGridItem(lights, x, y));

        g2.drawSubImage(
            image,
            // translateWorldX(x, y),
            // translateWorldY(x, y),
            posX + x * sizeX,
            posY + y * sizeY,
            // translateWorldX(x, y),
            // translateWorldY(x, y),
            (tileIndex % cols) * sizeX, Math.floor(tileIndex / cols) * sizeY, sizeX, sizeY
        );
    });

    for (i in 0...room.actors.length) {
        // if (items[i].item == -1) continue;
        final actor = room.actors[i];

        // + 90 becuase we draw facing up and not to the right
        g2.pushRotation(
            getRotDir(actor.facing) + toRadians(90),
            posX + actor.x * sizeX + 8,
            posY + actor.y * sizeY + 8
        );

        final tileIndex = 112 + actor.dna.body;
        g2.drawSubImage(
            image,
            posX + actor.x * sizeX,
            posY + actor.y * sizeY,
            (tileIndex % cols) * sizeX, Math.floor(tileIndex / cols) * sizeY, sizeX, sizeY
        );

        final tileIndex = (actor.hp > 0 ? 128 : 144) + actor.dna.eyes;
        g2.drawSubImage(
            image,
            posX + actor.x * sizeX,
            posY + actor.y * sizeY,
            (tileIndex % cols) * sizeX, Math.floor(tileIndex / cols) * sizeY, sizeX, sizeY
        );
        g2.popTransformation();
    }

    for (i in 0...room.things.length) {
        // if (items[i].item == -1) continue;
        final thing = room.things[i];

        final tileIndex = 160 + thing.type;

        g2.pushRotation(
            getRotDir(thing.facing) + toRadians(90),
            posX + thing.x * sizeX + 8,
            posY + thing.y * sizeY + 8
        );

        g2.drawSubImage(
            image,
            posX + thing.x * sizeX,
            posY + thing.y * sizeY,
            (tileIndex % cols) * sizeX, Math.floor(tileIndex / cols) * sizeY, sizeX, sizeY
        );
        g2.popTransformation();
    }

    final numberParticles = particles.filter(p -> p.number != null);
    final nonNumberParticles = particles.filter(p -> p.number == null);

    for (p in nonNumberParticles) {
        // if (items[i].item == -1) continue;

        g2.pushRotation(
            getRotDir(p.dir) + toRadians(90),
            posX + p.x * sizeX + 8,
            posY + p.y * sizeY + 8
        );

        g2.drawSubImage(
            image,
            posX + p.x * sizeX,
            posY + p.y * sizeY,
            (p.tile % cols) * sizeX, Math.floor(p.tile / cols) * sizeY, sizeX, sizeY
        );
        g2.popTransformation();
    }

    final numbers = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    for (p in numberParticles) {
        g2.color = p.color;
        final numString = (p.number + '').split('');
        for (i in 0...numString.length) {
            final num = numString[i];
            g2.drawSubImage(
                image,
                posX + (p.x * sizeX) + i * 4 + ((4 - numString.length) * 2),
                posY + p.y * sizeY,
                numbers.indexOf(num) * 8, 8, 5, 8
            );
        }
        g2.color = White;
    }
}