uRequire.org Website (based on http://gruntjs.com/ Website, with lame changes)
==========================

## Build

1. `npm install`
1. `grunt`


## Setup Development

1. `npm install`
2. `git clone https://github.com/anodynos/urequire/wiki` to `../uRequire.wiki`
3. `grunt build` - gets the latest docs, generates the site
4. use ```grunt watch``` if you are editing templates or less files. (Note: `MasterDefaultsConfig.coffee.md` and `ResourceConverters.coffee.md` aren't part of the wiki, but https://github.com/anodynos/urequire - edit them there)

## Run Server

1. `grunt server`

## Run Tests

1. Make sure the server is running
1. `grunt test`

## Notes

1. Default server port is : `8080`. Configured in the `Gruntfile`
