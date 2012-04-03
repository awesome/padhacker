(function() {
  var fromURL, init, project_data, setShare, toURL;

  if (typeof console === "undefined" || console === null) {
    console = {
      log: function() {}
    };
  }

  ({
    dir: function() {}
  });

  
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
;

  fromURL = function(ascii) {
    var data, escaped, lzwed, stringified;
    escaped = atob(ascii);
    lzwed = unescape(escaped);
    stringified = lzw.decompress(lzwed);
    data = JSON.parse(stringified);
    return data;
  };

  toURL = function(data) {
    var ascii, escaped, lzwed, stringified;
    stringified = JSON.stringify(data);
    lzwed = lzw.compress(stringified);
    escaped = escape(lzwed);
    ascii = btoa(escaped);
    return ascii;
  };

  project_data = {};

  setShare = function(key, value) {
    var url;
    project_data[key] = value;
    url = toURL(project_data);
    return $('#share-link').attr('href', "#" + url);
  };

  init = function() {
    var compileCoffee, compileHaml, compileSass, css_content, data_hash, defaults, hash, html_content, incoming_data, js_content, prev, renderPreview, render_timeout, source, type, yes_jquery, yes_underscore, _i, _len, _ref;
    defaults = {
      haml: "%h1 Hello, world!\n\n%p\n    Donec id elit non mi porta gravida at eget metus. Donec ullamcorper nulla non metus auctor fringilla. Morbi leo risus, porta ac consectetur ac, vestibulum at eros.\n\n%img{ src: \"http://code.alecperkins.net/projector/images/cyan-small.jpg\" }",
      sass: "p\n  :font-family Helvetica, Arial, sans-serif\n  :line-height 170%\n\nimg\n  :border 3px solid ccc\n  :border-radius 8px\n  :background f4f4f4\n  :padding 10px\n  &.selected\n    :border-color red",
      coffee: "img = $('img')\nimg.bind 'click', ->\n    img.toggleClass 'selected'",
      has_jquery: true,
      has_underscore: false
    };
    incoming_data = null;
    hash = window.location.hash;
    if ((hash != null ? hash.length : void 0) > 1) {
      data_hash = hash.substring(1);
      try {
        incoming_data = fromURL(data_hash);
      } catch (e) {
        console.log(e);
        alert('Invalid data in URL hash. Ignoring...');
      }
      if ((incoming_data != null) && confirm('Loading Padhacker data from hash will erase current project. Continue?')) {
        window.location.hash = '';
      } else {
        incoming_data = null;
      }
    }
    $('.tabs li').bind('click', function(e) {
      var target;
      $('textarea').hide();
      $('.tabs li.selected').removeClass('selected');
      target = $(e.currentTarget).attr('name');
      $(e.currentTarget).addClass('selected');
      return $("#" + target).show();
    });
    css_content = "";
    compileSass = function() {
      var sass_source;
      sass_source = $('#sass').val();
      localStorage.setItem('sass', sass_source);
      setShare('sass', sass_source);
      try {
        css_content = sass.render(sass_source);
        console.log("" + (new Date()) + " - compiled Sass");
        return renderPreview();
      } catch (error) {
        return console.log(error);
      }
    };
    $('#sass').bind('keyup', function(e) {
      var _ref;
      if (!((37 <= (_ref = e.which) && _ref <= 40))) return compileSass();
    });
    html_content = "";
    compileHaml = function() {
      var haml_source;
      haml_source = $('#haml').val();
      localStorage.setItem('haml', haml_source);
      setShare('haml', haml_source);
      try {
        html_content = Haml(haml_source)({});
        console.log("" + (new Date()) + " - compiled Haml");
        return renderPreview();
      } catch (error) {
        return console.log(error);
      }
    };
    $('#haml').bind('keyup', function(e) {
      var _ref;
      if (!((37 <= (_ref = e.which) && _ref <= 40))) return compileHaml();
    });
    js_content = "";
    compileCoffee = function() {
      var coffee_source;
      coffee_source = $('#coffee').val();
      localStorage.setItem('coffee', coffee_source);
      setShare('coffee', coffee_source);
      try {
        js_content = CoffeeScript.compile(coffee_source, {
          bare: true
        });
        console.log("" + (new Date()) + " - compiled");
        return renderPreview();
      } catch (error) {
        return console.log(error);
      }
    };
    $('#coffee').bind('keyup', function(e) {
      var _ref;
      if (!((37 <= (_ref = e.which) && _ref <= 40))) return compileCoffee();
    });
    yes_jquery = false;
    yes_underscore = false;
    $('#jquery').bind('click', function() {
      yes_jquery = !yes_jquery;
      localStorage.setItem('has_jquery', yes_jquery);
      setShare('has_jquery', yes_jquery);
      return renderPreview();
    });
    $('#underscore').bind('click', function() {
      yes_underscore = !yes_underscore;
      localStorage.setItem('has_underscore', yes_underscore);
      setShare('has_underscore', yes_underscore);
      return renderPreview();
    });
    $('textarea').bind('keydown', function(e) {
      var end, start;
      if (e.which === 9) {
        e.preventDefault();
        start = this.selectionStart;
        end = this.selectionEnd;
        this.value = this.value.substring(0, start) + "  " + this.value.substring(start);
        this.selectionStart = start + 2;
        return this.selectionEnd = start + 2;
      }
    });
    render_timeout = null;
    renderPreview = function(force) {
      var t;
      if (force == null) force = false;
      if (!(render_timeout != null)) {
        console.log(force);
        t = 500;
        render_timeout = setTimeout(function() {
          var data, frame;
          data = "<style>" + ((function() {
            return css_content;
          })()) + "</style>";
          if (yes_jquery) {
            data += '<script type="text/javascript" src="http://cdnjs.cloudflare.com/ajax/libs/jquery/1.6.2/jquery.min.js"></script>';
          }
          if (yes_underscore) {
            data += '<script type="text/javascript" src="http://cdnjs.cloudflare.com/ajax/libs/underscore.js/1.1.7/underscore-min.js"></script>';
          }
          data += "" + ((function() {
            return html_content;
          })());
          data += "<script>" + js_content + "</script>";
          frame = $('iframe')[0].contentWindow.document;
          frame.open();
          frame.write(data);
          frame.close();
          return render_timeout = null;
        }, t);
      }
    };
    $('.tabs li').first().trigger('click');
    $('#develop').splitter();
    if (incoming_data != null) {
      source = incoming_data;
    } else {
      source = defaults;
      if (localStorage.getItem('has_jquery') != null) {
        source.has_jquery = localStorage.getItem('has_jquery') === 'true';
      }
      if (localStorage.getItem('has_underscore') != null) {
        source.has_underscore = localStorage.getItem('has_underscore') === 'true';
      }
    }
    _ref = ['coffee', 'sass', 'haml'];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      type = _ref[_i];
      if (!(incoming_data != null)) {
        prev = localStorage.getItem(type);
        if (prev) source[type] = prev;
      }
      $("textarea#" + type).html(source[type]);
    }
    yes_jquery = source.has_jquery;
    $('#jquery').attr('checked', yes_jquery);
    yes_underscore = source.has_underscore;
    $('#underscore').attr('checked', yes_underscore);
    project_data = source;
    compileCoffee();
    compileSass();
    compileHaml();
    return renderPreview(true);
  };

  $(document).ready(init);

}).call(this);
