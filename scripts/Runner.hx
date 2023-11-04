import backend.Mods;
import psychlua.HScript;
import tjson.TJSON as Json;

function onCreate() {
    // GLOBAL SCRIPTS
    var globalFolders:Array = Mods.directoriesWithFile(Paths.getPreloadPath(), 'scripts/');
	for (folder in globalFolders)
		for (file in FileSystem.readDirectory(folder))
            if(StringTools.endsWith(file, ".fs")) game.initHScript(folder + file);

    // STAGE SCRIPTS
    game.startHScriptsNamed('stages/' + PlayState.curStage + '.fs');

    // SONG SCRIPTS
    var songFolders:Array<String> = Mods.directoriesWithFile(Paths.getPreloadPath(), 'data/' + game.songName + '/');
	for (folder in songFolders)
		for (file in FileSystem.readDirectory(folder))
			if(StringTools.endsWith(file, ".fs")) game.initHScript(folder + file);
}

var stageJson:Dynamic = null;
function onUpdatePost(elapsed) {
	stageJson = Json.parse(Paths.getTextFromFile('stages/' + PlayState.curStage + '.json'));
	if(stageJson != null && stageJson.zoomFactors != null) {
		if(mustHit)
			game.defaultCamZoom = stageJson.zoomFactors.boyfriend;
		else
			game.defaultCamZoom = stageJson.zoomFactors.opponent;
	}
}