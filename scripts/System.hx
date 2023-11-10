import backend.Character;
import backend.CoolUtil;
import backend.Mods;
import flixel.addons.display.FlxBackdrop;
import psychlua.FunkinLua;
import psychlua.LuaUtils;
import psychlua.ModchartSprite;
import tea.SScript;
import haxe.ds.StringMap;
import haxe.ds.Map;
import haxe.format.JsonParser;
import flixel.util.FlxSpriteUtil;
import flixel.math.FlxBasePoint as FlxPoint;
import objects.Note;
import Reflect;
import Std;
import Type;

using StringTools;
//PERSPECTIVE SPRITE CODE BY CYN, PORTED BY SEMI
var scriptFolders = [Paths.modFolders('scripts'), Paths.modFolders('data/'+game.songName), Paths.modFolders('stages')];
for (path in scriptFolders) {
	var scriptPath = FileSystem.readDirectory(path);
	if (scriptPath != null) {
		for (file in scriptPath) {
			if (StringTools.endsWith(file, ".fs")) {
				var characterMap = new StringMap();
				var characterNoteMap = new StringMap();
				var characterTypeMap = new StringMap();

				var perspectiveSprite = ["yea" => "bitch"];
				var perspective_vanish_offset = {x: 0, y: 0};

				perspectiveSprite.remove("yea"); //dont worry about it

				var sprite = {
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
					graphic: function(tag:String, width:Int = 256, height:Int = 256, ?x:Float = 0, ?y:Float = 0, ?color:String = 'FFFFFF') {
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
					polygon: function(obj:String, vertices:Array) {
						if (getFnfObject(obj) != null) {
							var shit = getFnfObject(obj);
							FlxSpriteUtil.drawPolygon(shit, vertices);
							return;
						}

						var object = Reflect.getProperty(LuaUtils.getTargetInstance(), obj);
						if (object != null) {
							FlxSpriteUtil.drawPolygon(object, vertices);
						}
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
						if (getFnfObject(obj) != null) {
							var shit = getFnfObject(obj);
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
						if (getFnfObject(obj) != null) {
							var shit = getFnfObject(obj);
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
						var spr = getFnfObject(obj);

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
						if (getFnfObject(obj, false) != null) {
							getFnfObject(obj, false).scrollFactor.set(scrollX, scrollY);
							return;
						}

						var object = Reflect.getProperty(LuaUtils.getTargetInstance(), obj);
						if (object != null) {
							object.scrollFactor.set(scrollX, scrollY);
						}
					},
					antialiasing: function(obj:String, check:Bool) {
						if (getFnfObject(obj) != null) {
							getFnfObject(obj).antialiasing = check;
							return;
						}

						var object = Reflect.getProperty(LuaUtils.getTargetInstance(), obj);
						if (object != null) {
							object.antialiasing = check;
						}
					},
					addPerspective: function(obj:String, depth:Float) {
						if(perspectiveSprite.exists(obj)) {
							perspectiveSprite.get(obj).depth = depth;
						} else {
							var shit = {
								x: getFnfObject(obj).x,
								y: getFnfObject(obj).y,
								width: getFnfObject(obj).width,
								height: getFnfObject(obj).height,
								scale: {x: getFnfObject(obj).scale.x, y: getFnfObject(obj).scale.y},
								depth:  depth
							};
							perspectiveSprite.set(obj, shit);

							getFnfObject(obj).shader = new FlxRuntimeShader('
								#pragma header

								uniform vec2 u_top;

								void main() {
									vec2 uv = vec2(openfl_TextureCoordv.x, 1.0 - openfl_TextureCoordv.y);
									
									vec2 bottom = vec2(0.0, 1.0), top = u_top;
									if (top.y > 1.0) {
										top.x /= top.y;
										bottom.y /= top.y;
										
										top.y = 1.0;
									} else if (top.x < 0.0) {
										top.x = 1.0 - top.x;
										
										top.y = 1.0 - (1.0 - top.y) / top.x;
										bottom.x = 1.0 - (1.0 - bottom.x) / top.x;
										
										top.x = 0.0;
									}
									
									vec2 side = mix(bottom, top, uv.y);
									uv = vec2((uv.x - side.x) / (side.y - side.x), 1.0 - uv.y);
									
									gl_FragColor = (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) ? vec4(0.0) : flixel_texture2D(bitmap, uv);
								}
							');
							getFnfObject(obj).shader.setFloatArray('u_top', [0, 10]);
							getFnfObject(obj).shader.setFloat('u_depth', depth);
						}
					},
					removePerspective: function(obj:String) {
						var sprite = perspectiveSprite.get(obj);
						if(perspectiveSprite.exists(obj)) {
							getFnfObject(obj).scale.set(sprite.scale.x, sprite.scale.y);
							getFnfObject(obj).updateHitbox();
							getFnfObject(obj).x = sprite.x;
							getFnfObject(obj).y = sprite.y;
							getFnfObject(obj).shader = null;

							perspectiveSprite.remove(obj);
						}
					},
					vanishOffset: function(x:Float, y:Float) {
						perspective_vanish_offset.x = x;
						perspective_vanish_offset.y = y;
					},
					addShader: function(obj:String, shader:String) {
						if (getFnfObject(obj) != null) {
							getFnfObject(obj).shader = game.createRuntimeShader(shader);
							return;
						}

						var object = Reflect.getProperty(LuaUtils.getTargetInstance(), obj);
						if (object != null) {
							object.shader = game.createRuntimeShader(shader);
						}
					},
					removeShader: function(obj:String) {
						if (getFnfObject(obj) != null) {
							getFnfObject(obj).shader = null;
							return;
						}

						var object = Reflect.getProperty(LuaUtils.getTargetInstance(), obj);
						if (object != null) {
							object.shader = null;
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

				var libs = [
					"sprite" => sprite,
					"math" => math,
					"system" => system,
					"character" => character,
					"screenWidth" => FlxG.width,
					"screenHeight" => FlxG.height
				];

				var fsScriptMap = SScript.global;
				function onCreate() {
					for (fnf in SScript.global.keys()) 
						if (StringTools.endsWith(fnf, ".hx")) fsScriptMap.remove(fnf);
					for (fs in fsScriptMap)
						for (k in libs.keys()) fs.set(k, libs[k]);

					game.callOnHScript('create');
				}

				function onMoveCamera(t)
					game.callOnHScript('sectionCamera');

				function onCreatePost()
					game.callOnHScript('createPost');

				function onUpdate(elapsed) {
					game.callOnHScript('update', [elapsed]);
					for (fnf in fsScriptMap)
						fnf.set("mustHit", PlayState.SONG.notes[game.curSection].mustHitSection);
				}

				function onUpdatePost(elapsed) {
					game.callOnHScript('updatePost', [elapsed]);
					var cam = {x: game.camGame.scroll.x + FlxG.width / 2 + perspective_vanish_offset.x, y: game.camGame.scroll.y + FlxG.height / 2 + perspective_vanish_offset.y};
					for(tag in perspectiveSprite.keys()) {
						var sprite = perspectiveSprite.get(tag);
						var vanish = {x: (cam.x - sprite.x) / sprite.width, y: 1 - (cam.y - sprite.y) / sprite.height};
						var top = [sprite.depth * vanish.x, sprite.depth * (vanish.x - 1) + 1];
						if(top[1]>1) {
							getFnfObject(tag).scale.set(sprite.scale.x * (1 + sprite.depth * (vanish.x - 1)), sprite.scale.y * (sprite.depth * vanish.y));
							getFnfObject(tag).updateHitbox();
						} else if(top[0]<0) {
							getFnfObject(tag).scale.set(sprite.scale.x * (1 - sprite.depth * (vanish.x)), sprite.scale.y * (sprite.depth * vanish.y));
							getFnfObject(tag).updateHitbox();
							getFnfObject(tag).x = sprite.x + sprite.width * sprite.depth * vanish.x;
						} else {
							getFnfObject(tag).scale.set(sprite.scale.x, sprite.scale.y * (sprite.depth * vanish.y));
							getFnfObject(tag).updateHitbox();
						}
						getFnfObject(tag).y = sprite.y + sprite.height * (1 - sprite.depth * Math.max(vanish.y, 0));
						getFnfObject(tag).shader.setFloatArray('u_top', top);
					}
				}

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

				//just getLuaObject but we can add more shit
				function getFnfObject(tag:String, ?text:Bool=true) {
					if(game.modchartSprites.exists(tag)) return game.modchartSprites.get(tag);
					if(text && game.modchartTexts.exists(tag)) return game.modchartTexts.get(tag);
					if(game.variables.exists(tag)) return game.variables.get(tag);
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
			}
		}
	}
}
