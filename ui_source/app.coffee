console ?=
    log: ->
    dir: ->
`
// from http://zapper.hodgers.com/files/javascript/lzw_test/
var lzw = {
	// Change this variable to output an xml safe string
	xmlsafe : false,
	compress : function(str){
		var dico = new Array();
		var skipnum = lzw.xmlsafe?5:0;
		for (var i = 0; i < 256; i++)
		{
			dico[String.fromCharCode(i)] = i;
		}
		if (lzw.xmlsafe)
		{
			dico["<"] = 256;
			dico[">"] = 257;
			dico["&"] = 258;
			dico["\""] = 259;
			dico["'"] = 260;
		}
		var res = "";
		var txt2encode = str;
		var splitStr = txt2encode.split("");
		var len = splitStr.length;
		var nbChar = 256+skipnum;
		var buffer = "";
		for (var i = 0; i <= len; i++)
		{
			var current = splitStr[i];
			if (dico[buffer + current] !== undefined)
			{
				buffer += current;
			}
			else
			{
				res += String.fromCharCode(dico[buffer]);
				dico[buffer + current] = nbChar;
				nbChar++;
				buffer = current;
			}
		}
		return res;
	},
	decompress : function (str)
	{
		var dico = new Array();
		var skipnum = lzw.xmlsafe?5:0;
		for (var i = 0; i < 256; i++)
		{
			var c = String.fromCharCode(i);
			dico[i] = c;
		}
		if (lzw.xmlsafe)
		{
			dico[256] = "<";
			dico[257] = ">";
			dico[258] = "&";
			dico[259] = "\"";
			dico[260] = "'";
		}
		var txt2encode = str;
		var splitStr = txt2encode.split("");
		var length = splitStr.length;
		var nbChar = 256+skipnum;
		var buffer = "";
		var chaine = "";
		var result = "";
		for (var i = 0; i < length; i++)
		{
			var code = txt2encode.charCodeAt(i);
			var current = dico[code];
			if (buffer == "")
			{
				buffer = current;
				result += current;
			}
			else
			{
				if (code <= 255+skipnum)
				{
					result += current;
					chaine = buffer + current;
					dico[nbChar] = chaine;
					nbChar++;
					buffer = current;
				}
				else
				{
					chaine = dico[code];
					if (chaine == undefined) chaine = buffer + buffer.slice(0,1);
					result += chaine;
					dico[nbChar] = buffer + chaine.slice(0, 1);
					nbChar++;
					buffer = chaine;
					
				}
			}
		}
		return result;
	}
}
`

fromURL = (ascii) ->
    escaped = atob(ascii)
    lzwed = unescape(escaped)
    stringified = lzw.decompress(lzwed)
    data = JSON.parse(stringified)
    return data

toURL = (data) ->
    stringified = JSON.stringify(data)
    lzwed = lzw.compress(stringified)
    escaped = escape(lzwed)
    ascii = btoa(escaped)
    return ascii

project_data = {}

setShare = (key, value) ->
    project_data[key] = value
    url = toURL(project_data)
    $('#share-link').attr('href',"##{ url }")

init = ->
    defaults =
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

    incoming_data = null
    hash = window.location.hash
    if hash?.length > 1
        data_hash = hash.substring(1)
        try
            incoming_data = fromURL(data_hash)
        catch e
            console.log e
            alert('Invalid data in URL hash. Ignoring...')
        
        if incoming_data? and confirm('Loading Padhacker data from hash will erase current project. Continue?')
            window.location.hash = ''
        else
            incoming_data = null
            
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
        setShare('sass',sass_source)
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
        setShare('haml',haml_source)
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
        setShare('coffee',coffee_source)
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
        setShare('has_jquery', yes_jquery)
        renderPreview()

    $('#underscore').bind 'click', ->
        yes_underscore = not yes_underscore
        localStorage.setItem('has_underscore',yes_underscore)
        setShare('has_underscore', yes_underscore)
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
                    data += '<script type="text/javascript" src="http://cdnjs.cloudflare.com/ajax/libs/jquery/1.6.2/jquery.min.js"></script>'
                if yes_underscore
                    data += '<script type="text/javascript" src="http://cdnjs.cloudflare.com/ajax/libs/underscore.js/1.1.7/underscore-min.js"></script>'
                data += "<script>#{ js_content }</script>"
                $('iframe').attr('src', encodeURI(data))
                render_timeout = null
            , t
        return

    $('.tabs li').first().trigger 'click'


    $('#develop').splitter()

    # sloppy!
    if incoming_data?
        source = incoming_data
    else
        source = defaults
        if localStorage.getItem('has_jquery')?
            source.has_jquery = localStorage.getItem('has_jquery') is 'true'
        if localStorage.getItem('has_underscore')?
            source.has_underscore = localStorage.getItem('has_underscore') is 'true'

    for type in ['coffee','sass','haml']
        if not incoming_data?
            prev = localStorage.getItem(type)
            if prev
                source[type] = prev
        $("textarea##{ type }").html source[type]

    yes_jquery = source.has_jquery
    $('#jquery').attr('checked',yes_jquery)
    yes_underscore = source.has_underscore
    $('#underscore').attr('checked',yes_underscore)

    project_data = source

    compileCoffee()
    compileSass()
    compileHaml()
    renderPreview(true)

$(document).ready init