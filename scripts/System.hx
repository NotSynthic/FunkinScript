import flixel.addons.display.FlxBackdrop;
import psychlua.LuaUtils;
import psychlua.FunkinLua;
import psychlua.ModchartSprite;
import tea.SScript;
import backend.CoolUtil;

var skewed:Bool = false;
var draw = {
	sprite: function(tag:String, ?image:String = null, ?x:Float = 0, ?y:Float = 0, ?animated:String = false, ?spriteType:String = "sparrow") {
		var leSprite:ModchartSprite = new ModchartSprite(x, y);
        if(animated) {
            LuaUtils.loadFrames(leSprite, image, spriteType);
        } else if(image != null && image.length > 0) {
            leSprite.loadGraphic(Paths.image(image));
        }
    
        game.modchartSprites.set(tag, leSprite);
        if(!animated) leSprite.active = true;
	},
	graphic: function(tag:String, width:Int = 256, height:Int = 256, ?x:Float = 0, ?y:Float = 0, color:String = 'FFFFFF') {
		var leSprite:ModchartSprite = new ModchartSprite(x, y);
		leSprite.makeGraphic(width, height, CoolUtil.colorFromString(color));
		game.modchartSprites.set(tag, leSprite);
		leSprite.active = true;
	},
	backdrop: function(tag:String, ?image:String = null, ?axes:String = null) {
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
	},
	add: function(tag:String, ?front:Bool = false) {
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
	}
};
var sprite = {
	scale: function(obj:String, x:Float, y:Float, ?updateHitbox:Bool = true) {
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
		luaTrace('sprite.scale: Couldnt find object: ' + obj, false, false, FlxColor.RED);
	},
	velocity: function(obj:String, x:Float, y:Float) {
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
		FunkinLua.luaTrace('sprite.velocity: Couldnt find object: ' + obj, false, false, FlxColor.RED);
	},
	screenCenter: function(obj:String, ?pos:String = 'xy') {
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
		FunkinLua.luaTrace("sprite.screenCenter: Object " + obj + " doesn't exist!", false, false, FlxColor.RED);
	},
	scrollFactor: function(obj:String, scrollX:Float, scrollY:Float) {
		if(game.getLuaObject(obj,false)!=null) {
			game.getLuaObject(obj,false).scrollFactor.set(scrollX, scrollY);
			return;
		}

		var object = Reflect.getProperty(LuaUtils.getTargetInstance(), obj);
		if(object != null) {
			object.scrollFactor.set(scrollX, scrollY);
		}
	}
}
var math = {
	lerp: function(a:Float, b:Float, t:Float) {
		return FlxMath.lerp(a, b, t * FlxG.elapsed); // fixed lerp ig?
	},
	roundDecimal: function(a:Float, b:Float, t:Float) {
		return FlxMath.lerp(a, b, t * FlxG.elapsed); // fixed lerp ig?
	}
}
var system = {
	get: function(variable:String, ?allowMaps:Bool = false) {
		var split:Array<String> = variable.split('.');
		if(split.length > 1)
			return LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split, true, true, allowMaps), split[split.length-1], allowMaps);
		return LuaUtils.getVarInArray(LuaUtils.getTargetInstance(), variable, allowMaps);
	},
	getFromClass: function(classVar:String, variable:String, ?allowMaps:Bool = false) {
		var myClass:Dynamic = Type.resolveClass(classVar);
		if(myClass == null)
		{
			FunkinLua.luaTrace('getFromClass: Class $classVar not found', false, false, FlxColor.RED);
			return null;
		}

		var split:Array<String> = variable.split('.');
		if(split.length > 1) {
			var obj:Dynamic = LuaUtils.getVarInArray(myClass, split[0], allowMaps);
			for (i in 1...split.length-1)
				obj = LuaUtils.getVarInArray(obj, split[i], allowMaps);

			return LuaUtils.getVarInArray(obj, split[split.length-1], allowMaps);
		}
		return LuaUtils.getVarInArray(myClass, variable, allowMaps);
	},
	set: function(variable:String, value:Dynamic, ?allowMaps:Bool = false) {
		var split:Array<String> = variable.split('.');
		if(split.length > 1) {
			LuaUtils.setVarInArray(LuaUtils.getPropertyLoop(split, true, true, allowMaps), split[split.length-1], value, allowMaps);
			return true;
		}
		LuaUtils.setVarInArray(LuaUtils.getTargetInstance(), variable, value, allowMaps);
		return true;
	},
	setFromClass: function(classVar:String, variable:String, value:Dynamic, ?allowMaps:Bool = false) {
		var myClass:Dynamic = Type.resolveClass(classVar);
		if(myClass == null)
		{
			FunkinLua.luaTrace('setFromClass: Class $classVar not found', false, false, FlxColor.RED);
			return null;
		}

		var split:Array<String> = variable.split('.');
		if(split.length > 1) {
			var obj:Dynamic = LuaUtils.getVarInArray(myClass, split[0], allowMaps);
			for (i in 1...split.length-1)
				obj = LuaUtils.getVarInArray(obj, split[i], allowMaps);

			LuaUtils.setVarInArray(obj, split[split.length-1], value, allowMaps);
			return value;
			}
		LuaUtils.setVarInArray(myClass, variable, value, allowMaps);
		return value;
	},
	print: function(text:Dynamic = '', ?color:String = 'WHITE') {
		debugPrint(text, color);
	}
}
function onCreate() {
    for (fnf in SScript.global) {
		fnf.set("draw", draw);
		fnf.set("sprite", sprite);
		fnf.set("math", math);
		fnf.set("system", system);
    }

	game.callOnHScript('create');
}

function onCreatePost() {
	game.callOnHScript('createPost');
}

function onUpdate(elapsed) {
	game.callOnHScript('update', [elapsed]);
	for (fnf in SScript.global) {
		fnf.set("mustHit", PlayState.SONG.notes[game.curSection].mustHitSection);
	}
}

function onUpdatePost(elapsed) {
	game.callOnHScript('updatePost', [elapsed]);
}

function onSectionHit() {
	game.callOnHScript('sectionHit');
}

function onStepHit() {
	game.callOnHScript('stepHit');
}

function onBeatHit() {
	game.callOnHScript('beatHit');
}