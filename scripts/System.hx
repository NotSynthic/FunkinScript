import flixel.addons.display.FlxBackdrop;
import psychlua.LuaUtils;
import psychlua.FunkinLua;
import psychlua.ModchartSprite;
import backend.CoolUtil;

function onCreate() {
    createGlobalCallback("get", function(variable:String, ?allowMaps:Bool = false) {
        var split:Array<String> = variable.split('.');
		if(split.length > 1)
			return LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split, true, true, allowMaps), split[split.length-1], allowMaps);
		return LuaUtils.getVarInArray(LuaUtils.getTargetInstance(), variable, allowMaps);
    });
    createGlobalCallback("getFromClass", function(classVar:String, variable:String, ?allowMaps:Bool = false) {
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
    });
    
    createGlobalCallback("set", function(variable:String, value:Dynamic, ?allowMaps:Bool = false) {
        var split:Array<String> = variable.split('.');
		if(split.length > 1) {
			LuaUtils.setVarInArray(LuaUtils.getPropertyLoop(split, true, true, allowMaps), split[split.length-1], value, allowMaps);
			return true;
		}
		LuaUtils.setVarInArray(LuaUtils.getTargetInstance(), variable, value, allowMaps);
		return true;
    });
	createGlobalCallback("setFromClass", function(classVar:String, variable:String, value:Dynamic, ?allowMaps:Bool = false) {
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
    });

	createGlobalCallback("write", function(text:Dynamic = '', ?color:String = 'WHITE') PlayState.instance.addTextToDebug(text, CoolUtil.colorFromString(color)));
}