{ spawn, exec }     = require 'child_process'
util                = require 'util'
fs                  = require 'fs'

{ File }            = require 'file-utils'
CoffeeScript        = require 'coffee-script'
Jade                = require 'jade'
Stylus              = require 'stylus'

walk                = require 'walk'
color               = require('ansi-color').set


INPUT_DIR = "#{ __dirname }/client"
OUTPUT_DIR = '.compiled_client'

file_list = []

ensureOutputDir = (cb) ->
    f = new File(OUTPUT_DIR)
    f.remove (err, removed) ->
        f.createDirectory (err, created) ->
            cb()
    return

discoverFiles = (cb) ->
    walker = walk.walk INPUT_DIR,
        followLinks: false

    walker.on 'file', (root, stat, next) ->
        file_list.push(root + '/' + stat.name)
        next()

    walker.on 'end', ->
        console.log "Found #{ file_list.length } files"
        cb()

processFiles = ->

    for file in file_list
        file_ext = file.split('.')
        file_ext = file_ext[file_ext.length - 1]
        switch file_ext
            when 'jade'
                processJade(file)
            when 'coffee'
                processCoffee(file)
            when 'styl'
                processStylus(file)
            else
                processOther(file)
    return

writeOutput = (output_file, output) ->
    console.log 'making', output_file
    f = File(output_file)
    console.log 'made', output_file, f
    f.createNewFile (err, created) ->
        console.log err, created
        fs.writeFile(f, output)

processJade = (file) ->
    output_file = file.replace(INPUT_DIR, OUTPUT_DIR).replace('.jade', '.html')
    fs.readFile file, (err, source) ->
        console.log file.replace(INPUT_DIR, '')
        templateFn = Jade.compile source.toString(),
            pretty: true
        output = templateFn()
        writeOutput(output_file, output)

processCoffee = (file) ->
    output_file = file.replace(INPUT_DIR, OUTPUT_DIR).replace('.coffee', '.js')
    fs.readFile file, (err, source) ->
        console.log file.replace(INPUT_DIR, '')
        output = CoffeeScript.compile(source.toString())
        writeOutput(output_file, output)

processStylus = (file) ->
    output_file = file.replace(INPUT_DIR, OUTPUT_DIR).replace('.styl', '.css')
    fs.readFile file, (err, source) ->
        console.log file.replace(INPUT_DIR, '')
        Stylus.render source.toString(), (err, output) ->
            writeOutput(output_file, output)

processOther = (file) ->
    output_file = file.replace(INPUT_DIR, OUTPUT_DIR)
    fs.readFile file, (err, output) ->
        console.log file.replace(INPUT_DIR, '')
        writeOutput(output_file, output)



task 'watch', 'Watch and compile shit', (opts) ->
    ensureOutputDir ->
        discoverFiles ->
            processFiles()

