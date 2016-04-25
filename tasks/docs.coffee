# * urequire.org - based on http://gruntjs.com/
module.exports = (grunt) ->
  fs = require "fs"
  exec = require("child_process").exec
  jade = require "jade"
  highlighter = require "highlight.js"
  docs = require("./lib/docs").init grunt
  wikiBase = "../urequire/wiki/"

  ### Custom task to generate urequire documentation###
  grunt.registerTask "docs", "Compile uRequire Docs to HTML", ->

    ### generate the docs based on the github wiki ###
    generateDocs = ->
      ###Helper Functions###

      ###Generate guides documentation ###
      generateGuides = ->
        grunt.log.ok "Generating Guides..."

        # API Docs
        sidebars = []
        sidebars.push getSidebarSection "## Introduction", "icon-document-alt-stroke"
        sidebars.push getSidebarSection "## Using & Configuration"
        sidebars.push getSidebarSection "## Module Authoring"
        sidebars.push getSidebarSection "## Conversion Templates"
        sidebars.push getSidebarSection "### Misc"

        names = grunt.file.expand(cwd: wikiBase, ["*", "!Blog-*", "!*.js"])
        names.forEach (name) ->
          title = name.replace(/-/g, " ").replace(".md", "")
          segment = name
            .replace(RegExp(" ", "g"), "-")
            .replace(".md", "").toLowerCase()
          src = wikiBase + name
          dest = "build/docs/" + name.replace(".md", "").toLowerCase() + ".html"

          grunt.file.copy src, dest,
            process: (src) ->
              try
                file = "src/tmpl/docs.jade"

                jade.compile(grunt.file.read(file), filename: file)(
                  page: "docs"
                  rootSidebar: true
                  pageSegment: segment
                  title: title
                  content: docs.anchorFilter marked docs.wikiAnchors src
                  sidebars: sidebars
                )
              catch e
                grunt.log.error e
                grunt.fail.warn "Jade failed to compile."

        grunt.log.ok "Created " + names.length + " files."


      ###
      Get sidebar list for section from index.md
      ###
      getSidebarSection = (section, iconClass) ->
        rMode = false
        l = undefined
        items = []

        # read the index.md of the wiki, extract the section links
        lines = fs.readFileSync("#{wikiBase}Home.md").toString().split "\n"
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
      marked = require "marked"

      # Set default marked options
      marked.setOptions
        gfm: true
        anchors: true
        wikiBase: "/"
        pedantic: false
        sanitize: true

        # callback for code highlighter
        highlight: (code)-> highlighter.highlight("coffeescript", code).value

      generateGuides()
      done(true)

    done = @async()

    if grunt.file.exists "#{wikiBase}Home.md"
      generateDocs()
    else
      grunt.log.error "Error: '#{wikiBase}Home.md' is missing..."
      done false