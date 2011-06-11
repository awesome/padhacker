init = ->
    source =
        haml: """%h1 Hello, world!
    %p
        Donec id elit non mi porta gravida at eget metus. Donec ullamcorper nulla non metus auctor fringilla. Morbi leo risus, porta ac consectetur ac, vestibulum at eros.
    %img{ src: "http://code.alecperkins.net/projector/images/cyan-small.jpg" }
    """
        sass: """
    p
      :font-family 'Trebuchet MS'
      &.selected
        :font-weight bold
    """
        coffee: """
    p = $('p')
    p.click ->
        p.toggleClass 'selected'
    """
        has_jquery: true


    $('.tabs li').click (e) ->
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

    $('#sass').keyup (e) ->
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

    $('#haml').keyup (e) ->
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

    $('#coffeescript').keyup (e) ->
        if not (37 <= e.which <= 40)
            compileCoffee()


    yes_jquery = false

    $('#jquery').click ->
        yes_jquery = not yes_jquery
        renderPreview()


    renderPreview = ->
        data = "data:text/html;charset=utf-8,"
        data += "\<style\>#{ css_content }\</style\>"
        data += "#{ html_content }"
        if yes_jquery
            data += '\<script type="application/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.6.1/jquery.min.js"\>\</script\>'
        data += "\<script\>#{ js_content }\</script\>"
        $('iframe').attr('src', encodeURI(data))
        return

    $('textarea').keydown (e) ->
        if e.which is 9
            e.preventDefault()

    $('.tabs li').first().click()


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
    if localStorage.getItem('has_jquery')
        source.has_jquery = localStorage.getItem('has_jquery')
    yes_jquery = source.has_jquery
    if source.has_jquery
        $('#jquery').attr('checked',true)

    compileCoffee()
    compileSass()
    compileHaml()
    renderPreview()

$(document).ready init