import flixel.addons.display.FlxBackdrop;
import psychlua.LuaUtils;
import psychlua.FunkinLua;
import psychlua.ModchartSprite;
import backend.CoolUtil;

function onCreate() {
    createGlobalCallback("drawSprite", function(tag:String, ?image:String = null, ?x:Float = 0, ?y:Float = 0, ?animated:String = false, ?spriteType:String = "sparrow") {
        var leSprite:ModchartSprite = new ModchartSprite(x, y);
		if(animated) {
            LuaUtils.loadFrames(leSprite, image, spriteType);
        } else if(image != null && image.length > 0) {
			leSprite.loadGraphic(Paths.image(image));
		}

		game.modchartSprites.set(tag, leSprite);
		if(!animated) leSprite.active = true;
    });

    createGlobalCallback("drawGraphic", function(tag:String, width:Int = 256, height:Int = 256, ?x:Float = 0, ?y:Float = 0, color:String = 'FFFFFF') {
        var leSprite:ModchartSprite = new ModchartSprite(x, y);
        leSprite.makeGraphic(width, height, CoolUtil.colorFromString(color));
        game.modchartSprites.set(tag, leSprite);
        leSprite.active = true;
    });

    createGlobalCallback("drawBackdrop", function(tag:String, ?image:String = null, ?axes:String = null) {
        var idk;
        switch(axes) {
            case "x": idk = 0x01;
            case "y": idk = 0x10;
            case "xy": idk = 0x11;
            case null: idk = 0x11;
        }
        var spr = new FlxBackdrop(Paths.image(image), idk);
        spr.antialiasing = ClientPrefs.data.antialiasing;
        game.modchartSprites.set(tag, spr);
    });

    createGlobalCallback("drawAdd", function(tag:String, ?front:Bool = false) {
        if(game.modchartSprites.exists(tag)) {
            var shit = game.modchartSprites.get(tag);
            if(front)
                LuaUtils.getTargetInstance().add(shit);
            else
            {
                if(!game.isDead)
                    game.insert(game.members.indexOf(LuaUtils.getLowestCharacterGroup()), shit);
                else
                    GameOverSubstate.instance.insert(GameOverSubstate.instance.members.indexOf(GameOverSubstate.instance.boyfriend), shit);
            }
        }
    });

    createGlobalCallback("drawSet", function(variable:String, value:Dynamic, allowMaps:Bool = false) {
        var split:Array<String> = variable.split('.');
		if(split.length > 1) {
			LuaUtils.setVarInArray(LuaUtils.getPropertyLoop(split, true, true, allowMaps), split[split.length-1], value, allowMaps);
			return true;
		}
		LuaUtils.setVarInArray(LuaUtils.getTargetInstance(), variable, value, allowMaps);
		return true;
    });

    createGlobalCallback("drawScale", function(obj:String, x:Float, y:Float, ?updateHitbox:Bool = true) {
        if(game.getLuaObject(obj)!=null) {
            var shit = game.getLuaObject(obj);
            shit.scale.set(x, y);
            if(updateHitbox) shit.updateHitbox();
            return;
        }

        var split:Array<String> = obj.split('.');
        var poop = LuaUtils.getObjectDirectly(split[0]);
        if(split.length > 1) {
            poop = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1]);
        }

        if(poop != null) {
            poop.scale.set(x, y);
            if(updateHitbox) poop.updateHitbox();
            return;
        }
        luaTrace('drawScale: Couldnt find object: ' + obj, false, false, FlxColor.RED);
    });

    createGlobalCallback("drawVelocity", function(obj:String, x:Float, y:Float) {
        if(game.getLuaObject(obj)!=null) {
            var shit = game.getLuaObject(obj);
            shit.velocity.set(x, y);
            return;
        }

        var split:Array<String> = obj.split('.');
        var poop = LuaUtils.getObjectDirectly(split[0]);
        if(split.length > 1) {
            poop = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1]);
        }

        if(poop != null) {
            poop.velocity.set(x, y);
            return;
        }
        FunkinLua.luaTrace('drawVelocity: Couldnt find object: ' + obj, false, false, FlxColor.RED);
    });

    createGlobalCallback("drawScreenCenter", function(obj:String, ?pos:String = 'xy') {
        var spr = game.getLuaObject(obj);

		if(spr==null){
			var split:Array<String> = obj.split('.');
			spr = LuaUtils.getObjectDirectly(split[0]);
			if(split.length > 1) {
				spr = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1]);
			}
		}

		if(spr != null)
		{
			switch(pos)
			{
				case 'x':
					spr.screenCenter(0x01);
					return;
				case 'y':
					spr.screenCenter(0x10);
					return;
				default:
					spr.screenCenter(0x11);
					return;
			}
		}
        FunkinLua.luaTrace("drawScreenCenter: Object " + obj + " doesn't exist!", false, false, FlxColor.RED);
    });
}