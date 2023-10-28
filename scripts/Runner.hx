import psychlua.HScript;
import backend.Mods;

function onCreate() {
    // GLOBAL SCRIPTS
    var globalFolders:Array = Mods.directoriesWithFile(Paths.getPreloadPath(), 'scripts/');
	for (folder in globalFolders)
		for (file in FileSystem.readDirectory(folder))
            if(StringTools.endsWith(file, ".fnf")) game.initHScript(folder + file);

    // STAGE SCRIPTS
    game.startHScriptsNamed('stages/' + PlayState.curStage + '.fnf');

    // SONG SCRIPTS
    var songFolders:Array<String> = Mods.directoriesWithFile(Paths.getPreloadPath(), 'data/' + game.songName + '/');
	for (folder in songFolders)
		for (file in FileSystem.readDirectory(folder))
			if(StringTools.endsWith(file, ".fnf")) game.initHScript(folder + file);
}