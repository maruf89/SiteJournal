'use strict';
var path = require('path');
var LIVERELOAD_PORT = 35729;
var lrSnippet = require('connect-livereload')({ port: LIVERELOAD_PORT });
var mountFolder = function (connect, dir) {
  return connect.static(path.resolve(dir));
};

// # Globbing
// for performance reasons we're only matching one level down:
// 'test/spec/{,*/}*.js'
// use this if you want to recursively match all subfolders:
// 'test/spec/**/*.js'

module.exports = function (grunt) {
  require('load-grunt-tasks')(grunt);
  require('time-grunt')(grunt);

  // configurable paths
  var yeomanConfig = {
    app: 'app',
    dist: 'dist'
  };

  var nodemonIgnoredFiles = [
    'README.md',
    'Gruntfile.js',
    'node-inspector.js',
    'karma.conf.js',
    '/.git/',
    '/node_modules/',
    //'/app/',
    '/dist/',
    //'*.styl',
    //'*.coffee',
    '/app/server.coffee',
    '/test/',
    '/coverage/',
    '/temp/',
    //'/.tmp',
    '*.txt',
    //'*.jade',
  ];

  try {
    yeomanConfig.app = require('./bower.json').appPath || yeomanConfig.app;
  } catch (e) {}

  grunt.initConfig({
    yeoman: yeomanConfig,
    stylus: {
      default: {
        options: {
          urlfunc: 'embedurl',
          compress: true,
          paths: [
            'node_modules/grunt-contrib-stylus/node_modules',
            '<%= yeoman.app %>/bower_components'
          ]
        },
        files: {
          '<%= yeoman.app %>/styles/main.css': '<%= yeoman.app %>/styles/stylus/main.styl'
        }
      }
    },
    watch: {
      server: {
        files: ['./{,*/}*.coffee'],
        tasks: ['coffee:server', 'wait:reload']
      },
      reload: {
        files: ['./{,*/}*.jade'],
        tasks: ['wait:reload']
      },
      // coffee: {
      //   files: ['<%= yeoman.app %>/scripts/{,*/}*.coffee'],
      //   tasks: ['coffee:dist', 'wait:reload']
      // },
      // coffeeTest: {
      //   files: ['test/spec/{,*/}*.coffee'],
      //   tasks: ['coffee:test']
      // },
      scripts: {
        files: ['<%= yeoman.app %>/scripts/{,*/}*.coffee'],
        tasks: ['copy:coffee', 'reload']
      },
      styles: {
        files: ['<%= yeoman.app %>/styles/{,*/}*.styl'],
        tasks: ['copy:stylus', 'reload']
      }
    },
    autoprefixer: {
      options: ['last 1 version'],
      dist: {
        files: [{
          expand: true,
          cwd: '.tmp/styles/',
          src: '{,*/}*.css',
          dest: '.tmp/styles/'
        }]
      }
    },
    connect: {
      options: {
        port: 9000,
        // Change this to '0.0.0.0' to access the server from outside.
        hostname: 'localhost'
      },
      livereload: {
        options: {
          middleware: function (connect) {
            return [
              lrSnippet,
              mountFolder(connect, '.tmp'),
              mountFolder(connect, yeomanConfig.app),
              require('./server') // your server packaged as a nodejs module
            ];
          }
        }
      },
      test: {
        options: {
          middleware: function (connect) {
            return [
              mountFolder(connect, '.tmp'),
              mountFolder(connect, 'test')
            ];
          }
        }
      },
      dist: {
        options: {
          middleware: function (connect) {
            return [
              mountFolder(connect, yeomanConfig.dist)
            ];
          }
        }
      }
    },
    open: {
      server: {
        //path: 'http://localhost:<%= express.livereload.options.port %>'
        url: 'https://localhost:<%= connect.options.port %>'
      }
    },
    clean: {
      dist: {
        files: [{
          dot: true,
          src: [
            '.tmp',
            '<%= yeoman.dist %>/*',
            '!<%= yeoman.dist %>/.git*'
          ]
        }]
      },
      server: '.tmp'
    },
    jshint: {
      options: {
        jshintrc: '.jshintrc'
      },
      all: [
        'Gruntfile.js',
        '<%= yeoman.app %>/scripts/{,*/}*.js'
      ]
    },
    coffee: {
      options: {
        sourceMap: true,
        sourceRoot: ''
      },
      dist: {
        files: [{
          expand: true,
          cwd: '<%= yeoman.app %>/scripts',
          src: '{,*/}*.coffee',
          dest: '.tmp/scripts',
          ext: '.js'
        }]
      },
      server: {
        files: [{
          expand: true,
          cwd: '<%= yeoman.app %>',
          //src: '{,*/}*.coffee',
          src: 'server.coffee',
          dest: '<%= yeoman.app %>',
          ext: '.js'
        }]
      },
      test: {
        files: [{
          expand: true,
          cwd: 'test/spec',
          src: '{,*/}*.coffee',
          dest: '.tmp/spec',
          ext: '.js'
        }]
      }
    },
    rev: {
      dist: {
        files: {
          src: [
            '<%= yeoman.dist %>/scripts/{,*/}*.js',
            '<%= yeoman.dist %>/styles/{,*/}*.css',
            '<%= yeoman.dist %>/images/{,*/}*.{png,jpg,jpeg,gif,webp,svg}',
            '<%= yeoman.dist %>/styles/fonts/*'
          ]
        }
      }
    },
    useminPrepare: {
      html: '<%= yeoman.app %>/index.html',
      options: {
        dest: '<%= yeoman.dist %>'
      }
    },
    usemin: {
      html: ['<%= yeoman.dist %>/{,*/}*.html'],
      css: ['<%= yeoman.dist %>/styles/{,*/}*.css'],
      options: {
        dirs: ['<%= yeoman.dist %>']
      }
    },
    imagemin: {
      dist: {
        files: [{
          expand: true,
          cwd: '<%= yeoman.app %>/images',
          src: '{,*/}*.{png,jpg,jpeg}',
          dest: '<%= yeoman.dist %>/images'
        }]
      }
    },
    svgmin: {
      dist: {
        files: [{
          expand: true,
          cwd: '<%= yeoman.app %>/images',
          src: '{,*/}*.svg',
          dest: '<%= yeoman.dist %>/images'
        }]
      }
    },

    htmlmin: {
      dist: {
        options: {
          removeCommentsFromCDATA: true,
          // https://github.com/yeoman/grunt-usemin/issues/44
          //collapseWhitespace: true,
          collapseBooleanAttributes: true,
          removeAttributeQuotes: true,
          removeRedundantAttributes: true,
          useShortDoctype: true,
          removeEmptyAttributes: true,
          removeOptionalTags: true
        },
        files: [{
          expand: true,
          cwd: '<%= yeoman.app %>',
          src: ['*.html', 'views/*.html', 'views/**/*.html'],
          dest: '<%= yeoman.dist %>'
        }]
      }
    },
    // Put files not handled in other tasks here
    copy: {
      stylus: {
        files: [{
          expand: true,
          dot: true,
          cwd: '<%= yeoman.app %>/styles',
          dest: '.tmp/styles/',
          src: '{,*/}*.{styl,css}'
        }, {
          src: '<%= yeoman.app %>/styles/main.styl',
          dest: '.tmp/styles/main.styl'
        }]
      },
      coffee: {
        expand: true,
        dot: true,
        cwd: '<%= yeoman.app %>/scripts',
        dest: '.tmp/scripts/',
        src: '{,*/}*.coffee'
      },
      dist: {
        files: [{
          expand: true,
          dot: true,
          cwd: '<%= yeoman.app %>',
          dest: '<%= yeoman.dist %>',
          src: [
            '*.{ico,png,txt}',
            '.htaccess',
            'bower_components/**/*',
            'images/{,*/}*.{gif,webp}',
            'styles/fonts/*'
          ]
        }, {
          expand: true,
          cwd: '.tmp/images',
          dest: '<%= yeoman.dist %>/images',
          src: [
            'generated/*'
          ]
        }]
      }
    },
    concurrent: {
      nodemon: {
        options: {
          logConcurrentOutput: true
        },
        tasks: [
          //'node-inspector',
          'nodemon:dev',
          //'wait:open'
        ]
      },
      server: [
        'copy:stylus',
	      'coffee:server',
        'copy:coffee'
      ],
      test: [
        'coffee',
        'copy:styles'
      ],
      dist: [
        'coffee',
        'copy:styles',
        'imagemin',
        'svgmin',
        'htmlmin'
      ]
    },
    karma: {
      unit: {
        configFile: 'karma.conf.js',
        singleRun: true
      }
    },
    cdnify: {
      dist: {
        html: ['<%= yeoman.dist %>/*.html']
      }
    },
    ngmin: {
      dist: {
        files: [{
          expand: true,
          cwd: '<%= yeoman.dist %>/scripts',
          src: '*.js',
          dest: '<%= yeoman.dist %>/scripts'
        }]
      }
    },
    shell: {
      trigger: {
        command: 'echo a > trigger.file'
      }
    },
    nodemon: {
      dev: {
        options: {
          file: 'app/server.js',
          args: ['development'],
          watchedExtensions: [
            'js',
            'jade',
            'styl'
            // This might cause an issue starting the server
            // See: https://github.com/appleYaks/grunt-express-workflow/issues/2
            //'coffee'
          ],
          // nodemon watches the current directory recursively by default
          watchedFolders: ['app'],
          debug: true,
          delayTime: 1,
          ignoredFiles: nodemonIgnoredFiles
        }
    },
    'node-inspector': {
        options: {
          //file: 'node-inspector.js',
          //watchedExtensions: [
          //    'js'
          //    // This might cause an issue starting the server
          //    // See: https://github.com/appleYaks/grunt-express-workflow/issues/2
          //    // 'coffee'
          //],
          //exec: 'node-inspector',
          //ignoredFiles: nodemonIgnoredFiles
          'web-port': 3000,
          'web-host': '173.234.60.108',
          'debug-port': 5857,
          'save-live-edit': false
        }
      }
    },
    uglify: {
      dist: {
        files: {
          '<%= yeoman.dist %>/scripts/scripts.js': [
            '<%= yeoman.dist %>/scripts/scripts.js'
          ]
        }
      }
    },
    wait: {
      options: {
        delay: 550
      },
      open: {
        options: {
          after: function() {
            grunt.task.run( 'waitDelay' );
          }
        }
      },
      reload: {
        options: {
          delay: 3500,
          after: function() {
            grunt.task.run( 'reload' );
          }
        }
      }
    }
  });

  grunt.registerTask('waitDelay', [ 'watch']);

  grunt.registerTask("reload", "reload Chrome on OS X", function() {
    require("child_process").exec("osascript " +
      "-e 'tell application \"Google Chrome\" " +
          "to tell the active tab of its first window' " +
      "-e 'reload' " +
      "-e 'end tell'");
  });

  grunt.registerTask('express', [
    'clean:server',
    'concurrent:server',
    //'coffee',
    //'htmlmin',

    // start karma server
    //'karma:app',

    'concurrent:nodemon'

  ]);

  grunt.registerTask('test', [
    'clean:server',
    'concurrent:test',
    'autoprefixer',
    'connect:test',
    'karma'
  ]);

  grunt.registerTask('build', [
    'clean:dist',
    'useminPrepare',
    'concurrent:dist',
    'autoprefixer',
    'concat',
    'copy:dist',
    'cdnify',
    'ngmin',
    'jade',
    'stylus',
    'cssmin',
    'uglify',
    'rev',
    'usemin'
  ]);

  grunt.registerTask('default', [
    'jshint',
    'test',
    'build'
  ]);
};
