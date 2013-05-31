var chaosBuild = require('spm-chaos-build');

module.exports = function (grunt) {
    chaosBuild.loadTasks(grunt);

    var config = chaosBuild.getConfig('javascripts', {
        outputDirectory : 'javascripts/sea-modules',
        gzip : 'all'
    });
    grunt.initConfig(config);

    grunt.registerTask('write-manifest', function () {
        var mapArr = grunt.config.get('md5map');
        var family = config.family;
        grunt.file.write('seajs-map.json', JSON.stringify(mapArr, null, '\t'));
    });

    grunt.registerTask('chaos-build', [
        'clean:dist', // delete dist direcotry first
        'transport:spm',  // src/* -> .build/src/*
        'concat:relative',  // .build/src/* -> .build/dist/*.js
        'concat:all',
        'uglify:js',  // .build/dist/*.js -> .build/dist/*.js
        'md5:js', // .build/dist/*.js -> dist/*-md5.js
        'clean:spm',
        'spm-newline',
        'compress',
        'write-manifest'
    ]);
};