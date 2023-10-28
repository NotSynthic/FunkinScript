import psychlua.FunkinLua;
import backend.Mods;

function onCreate() {
    // GLOBAL SCRIPTS
    var globalFolders:Array = Mods.directoriesWithFile(Paths.getPreloadPath(), 'scripts/');
	for (folder in globalFolders)
		for (file in FileSystem.readDirectory(folder))
            if(StringTools.endsWith(file, ".fnf")) new FunkinLua(folder + file);

    // STAGE SCRIPTS
    game.startLuasNamed('stages/' + game.curStage + '.fnf');

    // SONG SCRIPTS
    var songFolders:Array<String> = Mods.directoriesWithFile(Paths.getPreloadPath(), 'data/' + game.songName + '/');
	for (folder in songFolders)
		for (file in FileSystem.readDirectory(folder))
			if(StringTools.endsWith(file, ".fnf")) new FunkinLua(folder + file);
}