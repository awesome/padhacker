console ?=
    log: ->

init = ->
    source =
        haml: """%h1 Hello, world!

    %p
        Donec id elit non mi porta gravida at eget metus. Donec ullamcorper nulla non metus auctor fringilla. Morbi leo risus, porta ac consectetur ac, vestibulum at eros.

    %img{ src: "http://code.alecperkins.net/projector/images/cyan-small.jpg" }
    """
        sass: """
    p
      :font-family Helvetica, Arial, sans-serif
      :line-height 170%

    img
      :border 3px solid ccc
      :border-radius 8px
      :background f4f4f4
      :padding 10px
      &.selected
        :border-color red
    """
        coffee: """
    img = $('img')
    img.bind 'click', ->
        img.toggleClass 'selected'
    """
        has_jquery: true
        has_underscore: false


    $('.tabs li').bind 'click', (e) ->
        $('textarea').hide()
        $('.tabs li.selected').removeClass('selected')

        target = $(e.currentTarget).attr('name')
        $(e.currentTarget).addClass('selected')
        $("##{ target }").show()

    css_content = ""
    compileSass = ->
        sass_source = $('#sass').val()
        localStorage.setItem('sass',sass_source)
        try
            css_content = sass.render(sass_source)
            console.log "#{new Date()} - compiled Sass"
            renderPreview()
        catch error
            console.log error

    $('#sass').bind 'keyup', (e) ->
        if not (37 <= e.which <= 40)
            compileSass()

    html_content = ""
    compileHaml = ->
        haml_source = $('#haml').val()
        localStorage.setItem('haml',haml_source)
        try
            html_content = Haml(haml_source)({})
            console.log "#{new Date()} - compiled Haml"
            renderPreview()
        catch error
            console.log error

    $('#haml').bind 'keyup', (e) ->
        if not (37 <= e.which <= 40)
            compileHaml()


    js_content = ""
    compileCoffee = ->
        coffee_source = $('#coffee').val()
        localStorage.setItem('coffee',coffee_source)
        try
            js_content = CoffeeScript.compile coffee_source, bare: on
            console.log "#{new Date()} - compiled"
            renderPreview()
        catch error
            console.log error

    $('#coffee').bind 'keyup', (e) ->
        if not (37 <= e.which <= 40)
            compileCoffee()

    yes_jquery = false
    yes_underscore = false

    $('#jquery').bind 'click', ->
        yes_jquery = not yes_jquery
        localStorage.setItem('has_jquery',yes_jquery)
        renderPreview()

    $('#underscore').bind 'click', ->
        yes_underscore = not yes_underscore
        localStorage.setItem('has_underscore',yes_underscore)
        renderPreview()


    $('textarea').bind 'keydown', (e) ->
        if e.which is 9
            e.preventDefault()
            start = @selectionStart
            end = @selectionEnd
            @value = @value.substring(0,start) + "  " + @value.substring(start)
            @selectionStart = start + 2
            @selectionEnd = start + 2

    render_timeout = null
    renderPreview = (force=false)->
        if not render_timeout?
            console.log force
            t = 500
            render_timeout = setTimeout ->
                data = "data:text/html;charset=utf-8,"
                data += "<style>#{ (-> css_content)() }</style>"
                data += "#{ (-> html_content)() }"
                if yes_jquery
                    data += '<script type="application/javascript" src="http://cdnjs.cloudflare.com/ajax/libs/jquery/1.6.1/jquery.min.js"></script>'
                if yes_underscore
                    data += '<script type="application/javascript" src="http://cdnjs.cloudflare.com/ajax/libs/underscore.js/1.1.6/underscore-min.js"></script>'
                data += "<script>#{ js_content }</script>"
                $('iframe').attr('src', encodeURI(data))
                render_timeout = null
            , t
        return

    $('.tabs li').first().trigger 'click'


    $('#develop').splitter()

    # sloppy!
    for type in ['coffee','sass','haml']
        prev = localStorage.getItem(type)
        if prev
            console.log typeof prev
            source[type] = prev
        $("textarea##{ type }").html source[type]
        console.log $("textarea#{ type }")
        console.log source[type]
    if localStorage.getItem('has_jquery')?
        source.has_jquery = localStorage.getItem('has_jquery') is 'true'
    if localStorage.getItem('has_underscore')?
        source.has_underscore = localStorage.getItem('has_underscore') is 'true'

    yes_jquery = source.has_jquery
    $('#jquery').attr('checked',yes_jquery)
    yes_underscore = source.has_underscore
    $('#underscore').attr('checked',yes_underscore)

    compileCoffee()
    compileSass()
    compileHaml()
    renderPreview(true)

$(document).ready init