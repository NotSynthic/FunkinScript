import backend.CoolUtil;
import flixel.addons.display.FlxBackdrop;
import psychlua.FunkinLua;
import psychlua.LuaUtils;
import psychlua.ModchartSprite;
import tea.SScript;
import backend.Character;
import haxe.ds.StringMap;
import objects.Note;

using StringTools;

var characterMap = new StringMap();
var characterNoteMap = new StringMap();
var characterTypeMap = new StringMap();

var draw = {
	image: function(tag:String, ?image:String = null, ?x:Float = 0, ?y:Float = 0, ?animated:String = false, ?spriteType:String = "sparrow") {
		var leSprite:ModchartSprite = new ModchartSprite(x, y);
		if (animated) {
			LuaUtils.loadFrames(leSprite, image, spriteType);
		} else if (image != null && image.length > 0) {
			leSprite.loadGraphic(Paths.image(image));
		}

		game.modchartSprites.set(tag, leSprite);
		if (!animated)
			leSprite.active = true;
	},
	skewedimage: function(tag:String, ?image:String = null, ?x:Float = 0, ?y:Float = 0, ?animated:String = false, ?spriteType:String = "sparrow") {
		var leSprite:ModchartSprite = new ModchartSprite(x, y);
		if (animated) {
			LuaUtils.loadFrames(leSprite, image, spriteType);
		} else if (image != null && image.length > 0) {
			leSprite.loadGraphic(Paths.image(image));
		}

		game.modchartSprites.set(tag, leSprite);
		leSprite.shader = new FlxRuntimeShader('
			#pragma header
			vec2 uv = openfl_TextureCoordv.xy;
			vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
			#define iChannel0 bitmap
			#define texture flixel_texture2D
			#define fragColor gl_FragColor
			
			uniform float skew = 0.0;
			
			float lerpp(float a, float b, float t){
				return a + (b - a) * t;
			}

			void main(){
				float dfb = uv.y;
				vec4 c = vec4(0.0,0.0,0.0,0.0);
				vec2 pos = uv;
				pos.x = uv.x+(skew*dfb);
				if(pos.x > 0 && pos.x < 1){
					gl_FragColor = flixel_texture2D( bitmap, pos);
				}	
			}
		');

	},
	graphic: function(tag:String, width:Int = 256, height:Int = 256, ?x:Float = 0, ?y:Float = 0, color:String = 'FFFFFF') {
		var leSprite:ModchartSprite = new ModchartSprite(x, y);
		leSprite.makeGraphic(width, height, CoolUtil.colorFromString(color));
		game.modchartSprites.set(tag, leSprite);
		leSprite.active = true;
	},
	backdrop: function(tag:String, ?image:String = null, ?axes:String = null) {
		var idk;
		switch (axes) {
			case "x":
				idk = 0x01;
			case "y":
				idk = 0x10;
			case "xy":
				idk = 0x11;
			case null:
				idk = 0x11;
		}
		var spr = new FlxBackdrop(Paths.image(image), idk);
		spr.antialiasing = ClientPrefs.data.antialiasing;
		game.modchartSprites.set(tag, spr);
	},
	add: function(tag:String, ?front:Bool = false) {
		if (game.modchartSprites.exists(tag)) {
			var shit = game.modchartSprites.get(tag);
			if (front)
				LuaUtils.getTargetInstance().add(shit);
			else {
				if (!game.isDead)
					game.insert(game.members.indexOf(LuaUtils.getLowestCharacterGroup()), shit);
				else
					GameOverSubstate.instance.insert(GameOverSubstate.instance.members.indexOf(GameOverSubstate.instance.boyfriend), shit);
			}
		}
	},
	addAnimationByPrefix: function(obj:String, name:String, prefix:String, ?framerate:Int = 24, ?loop:Bool = true) {
		var obj:Dynamic = LuaUtils.getObjectDirectly(obj, false);
		if (obj != null && obj.animation != null) {
			obj.animation.addByPrefix(name, prefix, framerate, loop);
			if (obj.animation.curAnim == null) {
				if (obj.playAnim != null)
					obj.playAnim(name, true);
				else
					obj.animation.play(name, true);
			}
			return true;
		}
		return false;
	},
	addAnimation: function(obj:String, name:String, frames:Array, ?framerate:Int = 24, ?loop:Bool = true) {
		var obj:Dynamic = LuaUtils.getObjectDirectly(obj, false);
		if (obj != null && obj.animation != null) {
			obj.animation.add(name, frames, framerate, loop);
			if (obj.animation.curAnim == null) {
				obj.animation.play(name, true);
			}
			return true;
		}
		return false;
	},
	addAnimationByIndices: function(obj:String, name:String, prefix:String, indices:String, ?framerate:Int = 24, ?loop:Bool = false) {
		return LuaUtils.addAnimByIndices(obj, name, prefix, indices, framerate, loop);
	},
	playAnim: function(obj:String, name:String, ?forced:Bool = false, ?reverse:Bool = false, ?startFrame:Int = 0) {
		var obj:Dynamic = LuaUtils.getObjectDirectly(obj, false);
		if (obj.playAnim != null) {
			obj.playAnim(name, forced, reverse, startFrame);
			return true;
		} else {
			obj.animation.play(name, forced, reverse, startFrame);
			return true;
		}
		return false;
	},
	addOffset: function(obj:String, anim:String, x:Float, y:Float) {
		var obj:Dynamic = LuaUtils.getObjectDirectly(obj, false);
		if (obj != null && obj.addOffset != null) {
			obj.addOffset(anim, x, y);
			return true;
		}
		return false;
	},
	scale: function(obj:String, x:Float, y:Float, ?updateHitbox:Bool = true) {
		if (game.getLuaObject(obj) != null) {
			var shit = game.getLuaObject(obj);
			shit.scale.set(x, y);
			if (updateHitbox)
				shit.updateHitbox();
			return;
		}

		var split:Array<String> = obj.split('.');
		var poop = LuaUtils.getObjectDirectly(split[0]);
		if (split.length > 1) {
			poop = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length - 1]);
		}

		if (poop != null) {
			poop.scale.set(x, y);
			if (updateHitbox)
				poop.updateHitbox();
			return;
		}
		luaTrace('sprite.scale: Couldnt find object: ' + obj, false, false, FlxColor.RED);
	},
	velocity: function(obj:String, x:Float, y:Float) {
		if (game.getLuaObject(obj) != null) {
			var shit = game.getLuaObject(obj);
			shit.velocity.set(x, y);
			return;
		}

		var split:Array<String> = obj.split('.');
		var poop = LuaUtils.getObjectDirectly(split[0]);
		if (split.length > 1) {
			poop = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length - 1]);
		}

		if (poop != null) {
			poop.velocity.set(x, y);
			return;
		}
		FunkinLua.luaTrace('sprite.velocity: Couldnt find object: ' + obj, false, false, FlxColor.RED);
	},
	screenCenter: function(obj:String, ?pos:String = 'xy') {
		var spr = game.getLuaObject(obj);

		if (spr == null) {
			var split:Array<String> = obj.split('.');
			spr = LuaUtils.getObjectDirectly(split[0]);
			if (split.length > 1) {
				spr = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length - 1]);
			}
		}

		if (spr != null) {
			switch (pos) {
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
		if (game.getLuaObject(obj, false) != null) {
			game.getLuaObject(obj, false).scrollFactor.set(scrollX, scrollY);
			return;
		}

		var object = Reflect.getProperty(LuaUtils.getTargetInstance(), obj);
		if (object != null) {
			object.scrollFactor.set(scrollX, scrollY);
		}
	}
};

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
		if (split.length > 1)
			return LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split, true, true, allowMaps), split[split.length - 1], allowMaps);
		return LuaUtils.getVarInArray(LuaUtils.getTargetInstance(), variable, allowMaps);
	},
	getFromClass: function(classVar:String, variable:String, ?allowMaps:Bool = false) {
		var myClass:Dynamic = Type.resolveClass(classVar);
		if (myClass == null) {
			FunkinLua.luaTrace('getFromClass: Class $classVar not found', false, false, FlxColor.RED);
			return null;
		}

		var split:Array<String> = variable.split('.');
		if (split.length > 1) {
			var obj:Dynamic = LuaUtils.getVarInArray(myClass, split[0], allowMaps);
			for (i in 1...split.length - 1)
				obj = LuaUtils.getVarInArray(obj, split[i], allowMaps);

			return LuaUtils.getVarInArray(obj, split[split.length - 1], allowMaps);
		}
		return LuaUtils.getVarInArray(myClass, variable, allowMaps);
	},
	set: function(variable:String, value:Dynamic, ?allowMaps:Bool = false) {
		var split:Array<String> = variable.split('.');
		if (split.length > 1) {
			LuaUtils.setVarInArray(LuaUtils.getPropertyLoop(split, true, true, allowMaps), split[split.length - 1], value, allowMaps);
			return true;
		}
		LuaUtils.setVarInArray(LuaUtils.getTargetInstance(), variable, value, allowMaps);
		return true;
	},
	setFromClass: function(classVar:String, variable:String, value:Dynamic, ?allowMaps:Bool = false) {
		var myClass:Dynamic = Type.resolveClass(classVar);
		if (myClass == null) {
			FunkinLua.luaTrace('setFromClass: Class $classVar not found', false, false, FlxColor.RED);
			return null;
		}

		var split:Array<String> = variable.split('.');
		if (split.length > 1) {
			var obj:Dynamic = LuaUtils.getVarInArray(myClass, split[0], allowMaps);
			for (i in 1...split.length - 1)
				obj = LuaUtils.getVarInArray(obj, split[i], allowMaps);

			LuaUtils.setVarInArray(obj, split[split.length - 1], value, allowMaps);
			return value;
		}
		LuaUtils.setVarInArray(myClass, variable, value, allowMaps);
		return value;
	},
	print: function(text:Dynamic = '', ?color:String = 'WHITE') {
		debugPrint(text, color);
	}
};

var character = {
	create: function(character:String, type:String, ?noteType:String = '', ?defaultGFNote:Bool = true) {
		newCharacter(character, type, type == 'gf' ? (defaultGFNote ? 'GF Sing' : noteType) : noteType);
	},
	dance: function(character:String) {
		characterMap.get(character).dance();
	},
	playAnim: function(character:String, anim:String, forced:Bool) {
		characterMap.get(character).playAnim(anim, forced);
	}
};

function onCreate() {
	for (fnf in SScript.global) {
		fnf.set("draw", draw);
		fnf.set("math", math);
		fnf.set("system", system);
		fnf.set("character", character);
	}

	game.callOnHScript('create');
}

function onMoveCamera(t)
	game.callOnHScript('sectionCamera');

function onCreatePost()
	game.callOnHScript('createPost');

function onUpdate(elapsed) {
	game.callOnHScript('update', [elapsed]);
	for (fnf in SScript.global)
		fnf.set("mustHit", PlayState.SONG.notes[game.curSection].mustHitSection);
}

function onUpdatePost(elapsed)
	game.callOnHScript('updatePost', [elapsed]);

function onSectionHit()
	game.callOnHScript('sectionHit');

function onStepHit()
	game.callOnHScript('stepHit');

function onBeatHit() {
	game.callOnHScript('beatHit');

	for (char in characterMap)
		if (Std.isOfType(char, Character))
			if (game.curBeat % char.danceEveryNumBeats == 0
				&& char.animation.curAnim != null
				&& !StringTools.startsWith(char.animation.curAnim.name, 'sing')
				&& !char.stunned)
				char.dance();
}

function onCountdownTick(tick:Int, swagCounter:Int) {
	game.callOnHScript('countdownTick', [tick, swagCounter]);

	for (char in characterMap)
		if (Std.isOfType(char, Character))
			if (swagCounter % char.danceEveryNumBeats == 0
				&& char.animation.curAnim != null
				&& !StringTools.startsWith(char.animation.curAnim.name, 'sing')
				&& !char.stunned)
				char.dance();
}

function opponentNoteHit(note:Note)
	characterNote(note, false);

function goodNoteHit(note:Note)
	characterNote(note, false);

function noteMiss(note:Note)
	characterNote(note, true);

function noteMissPress(note:Note)
	characterNote(note, true);

function characterNote(note:Note, ?miss:Bool = false)
	if (characterMap.get(characterNoteMap.get(note.noteType)) != null)
		charSing(characterMap.get(characterNoteMap.get(note.noteType)), note, miss, characterTypeMap.get(characterNoteMap.get(note.noteType)));

function charSing(char:Character, note:Note, miss:Bool, charType:String) {
	var missSuffix:String = miss ? 'miss' : '';

	char.playAnim(game.singAnimations[Std.int(Math.abs(Math.min(game.singAnimations.length - 1, note.noteData)))] + missSuffix, true);
	char.holdTimer = 0;
}

function newCharacter(newCharacter:String, type:String, ntype:String)
	switch (type) {
		case 'bf':
			if (!game.boyfriendMap.exists(newCharacter)) {
				var newBoyfriend:Character = new Character(0, 0, newCharacter, true);
				game.boyfriendMap.set(newCharacter, newBoyfriend);
				game.boyfriendGroup.add(newBoyfriend);
				game.startCharacterPos(newBoyfriend);
				game.startCharacterScripts(newBoyfriend.curCharacter);
				characterMap.set(newCharacter, newBoyfriend);
				characterNoteMap.set(ntype, newCharacter);
				characterTypeMap.set(newCharacter, 'bf');
			}
		case 'dad':
			if (!game.dadMap.exists(newCharacter)) {
				var newDad:Character = new Character(0, 0, newCharacter);
				game.dadMap.set(newCharacter, newDad);
				game.dadGroup.add(newDad);
				game.startCharacterPos(newDad, true);
				game.startCharacterScripts(newDad.curCharacter);
				characterMap.set(newCharacter, newDad);
				characterNoteMap.set(ntype, newCharacter);
				characterTypeMap.set(newCharacter, 'dad');
			}
		case 'gf':
			if (game.gf != null && !game.gfMap.exists(newCharacter)) {
				var newGf:Character = new Character(0, 0, newCharacter);
				newGf.scrollFactor.set(0.95, 0.95);
				game.gfMap.set(newCharacter, newGf);
				game.gfGroup.add(newGf);
				game.startCharacterPos(newGf);
				game.startCharacterScripts(newGf.curCharacter);
				characterMap.set(newCharacter, newGf);
				characterNoteMap.set(ntype, newCharacter);
				characterTypeMap.set(newCharacter, 'gf');
			}
	}
