import Math;
import flixel.math.FlxMath;

/**
 * Literally just a module with haxe math stuff
 */
function onCreate() {
    createGlobalCallback("lerp", function(a:Float, b:Float, t:Float) {
        return FlxMath.lerp(a, b, t * FlxG.elapsed); // fixed lerp ig?
    });

    createGlobalCallback("roundDecimal", function(val:Float, round:Int) {
        return FlxMath.roundDecimal(val, round);
    });
}