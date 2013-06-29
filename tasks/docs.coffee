#
# * grunt docs
# * http://gruntjs.com/
# *
# * Copyright (c) 2013 grunt contributors
# * Licensed under the MIT license.
#
module.exports = (grunt) ->
  "use strict"
  fs = require("fs")
  exec = require("child_process").exec
  jade = require("jade")
  highlighter = require("highlight.js")
  docs = require("./lib/docs").init(grunt)

  ###
  Custom task to generate grunt documentation
  ###
  grunt.registerTask "docs", "Compile Grunt Docs to HTML", ->

    ###
    generate the docs based on the github wiki
    ###
    generateDocs = ->
      ###
      Helper Functions
      ###

      ###
      Generate grunt guides documentation
      ###
      generateGuides = ->
        grunt.log.ok "Generating Guides..."
        base = "tmp/wiki/"

        # API Docs
        sidebars = []
        sidebars.push getSidebarSection "## Introduction", "icon-document-alt-stroke"
        sidebars.push getSidebarSection "## Module Authoring"
        sidebars.push getSidebarSection "## Using & Configuration"
        sidebars.push getSidebarSection "## Conversion Templates"
        sidebars.push getSidebarSection "### Misc"
        sidebars.push getSidebarSection("### Community")
        sidebars.push getSidebarSection("### Migration guides")

        names = grunt.file.expand(cwd: base, ["*", "!Blog-*", "!*.js"])
        names.forEach (name) ->
          title = name.replace(/-/g, " ").replace(".md", "")
          segment = name
            .replace(RegExp(" ", "g"), "-")
            .replace(".md", "").toLowerCase()
          src = base + name
          dest = "build/docs/" + name.replace(".md", "").toLowerCase() + ".html"

          grunt.file.copy src, dest,
            process: (src) ->
              try
                file = "src/tmpl/docs.jade"
                templateData =
                  page: "docs"
                  rootSidebar: true
                  pageSegment: segment
                  title: title
                  content: docs.anchorFilter(marked(docs.wikiAnchors(src)))
                  sidebars: sidebars

                return jade.compile(grunt.file.read(file),
                  filename: file
                )(templateData)
              catch e
                grunt.log.error e
                grunt.fail.warn "Jade failed to compile."

        grunt.log.ok "Created " + names.length + " files."

#      ###
#      Generate config documentation
#      ###
#      generateConfigDocs = ->
#        grunt.log.ok "Generating Config Docs..."
#
#        # config Docs
#        sidebars = []
#        base = "tmp/wiki/"
#        names = grunt.file.expand(
#          cwd: base
#        , ["config.*.md"])
#        names = names.map((name) ->
#          name.substring 0, name.length - 3
#        )
#
#        # the default api page is special
#        names.push "config"
#
#        # TODO: temporary store for these
##        names.push "Inside-Tasks"
##        names.push "Exit-Codes"
#
#        # get docs sidebars
#        sidebars[0] = getSidebarSection("## Config", "icon-cog")
#        sidebars[1] = getSidebarSection("### Other")
#        names.forEach (name) ->
#          src = base + name + ".md"
#          dest = "build/config/" + name.toLowerCase() + ".html"
#          grunt.file.copy src, dest,
#            process: (src) ->
#              try
#                file = "src/tmpl/docs.jade"
#                templateData =
#                  page: "config"
#                  pageSegment: name.toLowerCase()
#                  title: name.replace(/-/g, " ")
#                  content: docs.anchorFilter(marked(docs.wikiAnchors(src)))
#                  sidebars: sidebars
#
#                return jade.compile(grunt.file.read(file),
#                  filename: file
#                )(templateData)
#              catch e
#                grunt.log.error e
#                grunt.fail.warn "Jade failed to compile."
#
#
#        grunt.log.ok "Created " + names.length + " files."

      ###
      Get sidebar list for section from index.md
      ###
      getSidebarSection = (section, iconClass) ->
        rMode = false
        l = undefined
        items = []

        # read the index.md of the wiki, extract the section links
        lines = fs.readFileSync("tmp/wiki/Home.md").toString().split("\n")
        for l of lines
          line = lines[l]

          # choose a section of the file
          if line is section
            rMode = true

          # end of section
          else rMode = false  if line.substring(0, 2) is "##"
          if rMode and line.length > 0
            item = line.replace(/#/g, "").replace("]]", "").replace("* [[", "")
            url = item
            if item[0] is " "

              # TODO: clean this up...
              if iconClass
                items.push
                  name: item.substring(1, item.length)
                  icon: iconClass

              else
                items.push name: item.substring(1, item.length)
            else
              items.push
                name: item
                url: url.replace(RegExp(" ", "g"), "-")
                  .replace(/\`/g, "")
                  .toLowerCase()

        items

      # marked markdown parser
      marked = require("marked")

      # Set default marked options
      marked.setOptions
        gfm: true
        anchors: true
        base: "/"
        pedantic: false
        sanitize: true

        # callback for code highlighter
        highlight: (code) ->
          highlighter.highlight("coffeescript", code).value

      # urequire guides - wiki articles that are not part of the urequire config
      generateGuides()

      # urequire config docs - wiki articles that start with 'config.*'
      # generateConfigDocs()
      done(true)

    done = @async()
    # clean the wiki directory, clone a fresh copy
#    exec "git clone " + grunt.config.get("wiki_url") + " tmp/wiki", (error) ->
#      grunt.log.warn "Warning: Could not clone the wiki! Trying to use a local copy..."  if error
    if grunt.file.exists("tmp/wiki/" + grunt.config.get("wiki_file"))
      # confirm the wiki exists, if so generate the docs
      generateDocs()
    else
      # failed to get the wiki
      grunt.log.error "Error: The wiki is missing..."
      done false