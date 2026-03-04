const project = new Project('br');

// alternative to project.addAssets('assets/**');
project.addAssets('assets/images/**/*.png');
project.addAssets('assets/data/**/*.json');
project.addAssets('assets/data/**/*.ldtk');
project.addAssets('assets/data/**/*.tmx');
project.addAssets('assets/music/**/*.wav');
project.addAssets('assets/sounds/**/*.wav');
project.addAssets('assets/fonts/**/*.ttf');
project.addAssets('assets/fonts/**/*.fnt');
project.addAssets('assets/fonts/**/*.png');
// TODO: remove this for non-web builds
project.addAssets('assets/index.html');

project.addShaders('shaders/**');
project.addSources('src');
project.addDefine('harness');
// project.addDefine('logging');

// project.addDefine('is_ng');
// project.addLibrary('newgrounds');

project.addDefine('kha_html5_disable_automatic_size_adjust');

// to send metrics locally or live, if at all.
// project.addDefine('sends_metrics');
// project.addDefine('localhost');

// project.icon = 'assets/images/icon.png';

resolve(project);
