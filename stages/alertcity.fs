function create() {
    sprite.skewedImage('hi', 'sick', 0, 0);
    sprite.add('hi');
}

function createPost() {
    system.set('gf.visible', false);

    character.create('trolljakAlert', 'gf', '', true);
    character.create('dad', 'bf', '');
}