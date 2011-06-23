# compile haml
# compile coffee
# compress js
# compile sass
# copy ui to tmp
# checkout gh-pages
# rebase gh-pages on master
# move files from tmp to /
# remove tmp
# commit gh-pages


exec    = require('child_process').exec
child   = null

task 'pages', 'min js, compile sass, commit to pages', (options) ->
    'haml'
    sass_done = coffee_done = haml_done = false
    
    exec "haml ui_source/index.haml ui/index.html", (error, stdout, stderr) ->
        console.log "stdout: #{ stdout }"
        if not error?
            haml_done = true
            pages()

    exec "coffee -o ui/ -c ui_source/app.coffee", (error, stdout, stderr) ->
        console.log "stdout: #{ stdout }"
        if not error?
            exec "closure --js_output_file ui/app-min.js --js ui/app.js", (error, stdout, stderr) ->
                if not error?
                    exec "mv ui/app-min.js  ui/app.js", (error, stdout, stderr) ->
                        if not error?
                            coffee_done = true
                            pages()

    exec "compass compile -f --sass-dir ui_source/ --css-dir ui/ -s compressed", (error, stdout, stderr) ->
        console.log "stdout: #{ stdout }"
        if not error?
            sass_done = true
            pages()

    pages = ->
        
    
        if sass_done and coffee_done and haml_done
            console.log 'pages'
            files_to_delete = [
                'Cakefile'
                'develop.sh'
            ]
            dirs_to_delete = [
                'ui'
                'ui_source'
            ]
            command = 'mv ui/* .;'
            
            command += "rm #{ f };" for f in files_to_delete
            command += "rm -r #{ d };" for d in dirs_to_delete
            
            exec command, (error, stdout, stderr) ->
            #     exec "mv tmp/ui/ ../;rm -r tmp/", (error, stdout, stderr) ->
            #         exec "git checkout -B gh-pages;", (error, stdout, stderr) ->

            # checkout

    # "closure --js_output_file templates/js/#{ file }-min.js --js templates/js/#{ file }.js" for file in js_files)
    # commands.push "compass compile -f -s compressed"

    # for command in commands
    #     exec command, (error, stdout, stderr) ->
    #         console.log "stdout: #{ stdout }"
    #         console.log "stderr: #{ stderr }"
    #         if error?
    #             console.log "exec error: #{ error }"