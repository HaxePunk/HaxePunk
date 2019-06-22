let project = new Project('{{PROJECT_NAME}}');

project.addLibrary('HaxePunk');
project.addSources('source');

// Add resources
project.addAssets('assets/**', {
    nameBaseDir: 'assets',
    destination: '{dir}/{name}',
    name: '{dir}/{name}'
});

// Add shaders
project.addShaders('shaders/**');

project.addDefine('hxp_debug'); // NOTE: COMMENT THIS OUT IF YOU ARE RELEASING

/**
 * Todo: There is still a lot of configuration stuff related to assets and other to transfer.
 */

resolve(project);
