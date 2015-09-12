module.exports = (grunt) ->

  require('time-grunt')(grunt)
  require('load-grunt-tasks')(grunt)

  grunt.initConfig

    pkg: grunt.file.readJSON("package.json")

    # --------------------------------------------------------
    # Browserify our app/test files
    # --------------------------------------------------------

    browserify:
      test:
        src:  "client/spec/spec-main.coffee"
        dest: "build/js/spec-main.js"
        options:
          transform: [
            ['browserify-coffee-coverage', {instrumentor: 'istanbul', ignore: '**/spec/**'}]
          ]
          debug: true

    # --------------------------------------------------------
    # Clean generated files
    # --------------------------------------------------------

    clean:
      test: ["build", 'coverage']

    # --------------------------------------------------------
    # Copy resources to the build directory
    # --------------------------------------------------------

    copy:
      test:
        files: [
          {expand: true, cwd: "client/spec/public/", src: "**",       dest: "build/"}
          {expand: true, cwd: "node_modules/mocha",  src: 'mocha.js', dest: "build/js/"}
          {expand: true, cwd: "node_modules/mocha",  src: 'mocha.css',dest: "build/css/"}
          {expand: true, cwd: "node_modules/chai",   src: 'chai.js',  dest: "build/js/"}
        ]

    # --------------------------------------------------------
    # Run Mocha specs
    # --------------------------------------------------------

    mocha:
      test:
        src: "build/index.html"
        options:
          run: true
          reporter: 'Spec'
          log: true
          logErrors: true
          coverage:
            lcovReport: 'coverage/'

  # --------------------------------------------------------
  # Grunt Tasks
  # --------------------------------------------------------

  grunt.registerTask 'default', ['clean', 'copy', 'browserify', 'mocha']

  grunt.option 'force', true