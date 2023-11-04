function create() {
	system.setFromClass('GameOverSubstate', 'characterName', 'bf_ourple');
	sprite.graphic('bg', screenWidth * 2, screenHeight * 2);
	sprite.antialiasing('bg', false);
	sprite.scrollFactor('bg', 0, 0);
	sprite.screenCenter('bg');
	sprite.add('bg');
}

function createPost() {
	system.set('gf.visible', false);
}