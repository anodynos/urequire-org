module.exports = (grunt) ->
  _ = grunt.util._
  
  grunt.initConfig
    
    server_port: 8080

    # clean directories
    clean:
      build: ["build/"]
      tmp: ["tmp/"]

    # compile less -> css
    less:
      development:
        options:
          paths: ["src/less"]

        files:
          "build/css/main.css": "src/less/main.less"

      production:
        options:
          paths: ["src/less"]
          yuicompress: true

        files:
          "build/css/main.css": "src/less/main.less"

    watch:
      less:
        files: "src/less/*.less"
        tasks: ["less:development"]

#      tmpl:
#        files: "src/tmpl/**/*.js"
#        tasks: ["jade", "default"]

#      js:
#        files: "src/js/**"
#        tasks: ["concat"]

      other:
        files: "src/img/**"
        tasks: ["default"]

      jade:
        files: "src/tmpl/**"
        tasks: ["jade", "docs", "blog"] #"concat"

      docs:
        files: "../uRequire.wiki/**"
        tasks: ["docs"]
    
    # compile page layouts
    jade:
      notfound:
        options:
          data:
            page: "notfound"
            title: "404 Not Found"

        files:
          "build/404.html": "src/tmpl/404.jade"

#    concat:
#      # if we add more js, modify this properly
#      plugins:
#        src: ["src/js/**/*.js"]
#        dest: "build/js/javascripts.js"

    jshint:
      all: ["tasks/*.js"]
      options:
        curly: true
        eqeqeq: true
        immed: true
        latedef: true
        newcap: true
        noarg: true
        sub: true
        undef: true
        unused: true
        boss: true
        eqnull: true
        node: true
        es5: true

    
    # copy site source files
    copy:
      assets:
        files: [
          expand: true
          cwd: "src/"
          src: ["img/**", "fonts/**", "js/vendor/lib/modernizr.min.js"]
          dest: "build/"
        ]

      root:
        files: [
          expand: true
          cwd: "src/"
          src: ["*"]
          dest: "build/"
          filter: "isFile"
        ]

    nodeunit:
      all: ["test/*_test.js"]

    shell:
      coffee: command: "coffee -cb -o ./build ./src"

  grunt.loadNpmTasks plugin for plugin in [
    "grunt-shell"
    "grunt-contrib-clean"
    "grunt-contrib-jshint"
  #  "grunt-contrib-concat"
    "grunt-contrib-watch"
    "grunt-contrib-less"
    "grunt-contrib-jade"
    "grunt-contrib-copy"
    "grunt-contrib-nodeunit"
  ]

  grunt.loadTasks "tasks" # getWiki, docs tasks

  ### shortcuts generation ###
  splitTasks = (tasks)-> if !_.isString tasks then tasks else (_.filter tasks.split(' '), (v)-> v)
  grunt.registerTask shortCut, splitTasks tasks for shortCut, tasks of {
    "default": ["dev"]
    "build": ["shell:coffee", "copy", "jade", "docs", "blog"] #"concat" #"plugins",
    "dev": ["jade", "docs", 'serve']
    "full": ["clean", "build", "less:development"] #"jshint",
    "test": ["nodeunit"]
    "serve": ["server"]

    # generic shortcuts
    "c": "clean"
    "d": "full"
    "t": "test"
    "b": "build"
    # IDE shortcuts
    "alt-c": "c"
    "alt-b": "b"
    "alt-t": "t"
    "alt-d": "full"
  } when tasks


# todo: report 'issue' to coffeescript
#val1 = -> 'val1'
#val2 = 'val2'
#
#myObjectCreation =
#  'bar1': val1
#   bar2 : val2
#
#console.log myObjectCreation