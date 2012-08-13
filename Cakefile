{ spawn, exec }     = require 'child_process'
util                = require 'util'
fs                  = require 'fs'

File                = require 'file'
CoffeeScript        = require 'coffee-script'
Jade                = require 'jade'
Stylus              = require 'stylus'

walk                = require 'walk'
color               = require('ansi-color').set


INPUT_DIR = "#{ __dirname }/client"
OUTPUT_DIR = '.compiled_client'

file_list = []

ensureOutputDir = (cb) ->
    File.walkSync OUTPUT_DIR, (path, dirs, files) ->
        files.forEach (f) ->
            fs.unlink(path + '/' + f)
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

processFile = (file) ->
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
    paths = output_file.split('/')
    file_name = paths.pop()

    File.mkdirs paths.join('/'), '0755', ->
        fs.writeFile(output_file, output)
        console.log 'made', paths


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
        if err?
            throw err
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

watchFiles = ->
    for file in file_list
        do ->
            this_file = file
            fs.watch this_file, (event, filename) ->
                console.log event, filename
                processFile(this_file)

task 'watch', 'Watch and compile shit', (opts) ->
    ensureOutputDir ->
        discoverFiles ->
            for file in file_list
                processFile(file)
            watchFiles()

