(function() {
  var init;
    if (typeof console !== "undefined" && console !== null) {
    console;
  } else {
    console = {
      log: function() {}
    };
  };
  init = function() {
    var compileCoffee, compileHaml, compileSass, css_content, html_content, js_content, prev, renderPreview, render_timeout, source, type, yes_jquery, yes_underscore, _i, _len, _ref;
    source = {
      haml: "%h1 Hello, world!\n\n%p\n    Donec id elit non mi porta gravida at eget metus. Donec ullamcorper nulla non metus auctor fringilla. Morbi leo risus, porta ac consectetur ac, vestibulum at eros.\n\n%img{ src: \"http://code.alecperkins.net/projector/images/cyan-small.jpg\" }",
      sass: "p\n  :font-family Helvetica, Arial, sans-serif\n  :line-height 170%\n\nimg\n  :border 3px solid ccc\n  :border-radius 8px\n  :background f4f4f4\n  :padding 10px\n  &.selected\n    :border-color red",
      coffee: "img = $('img')\nimg.bind 'click', ->\n    img.toggleClass 'selected'",
      has_jquery: true,
      has_underscore: false
    };
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
      if (!((37 <= (_ref = e.which) && _ref <= 40))) {
        return compileSass();
      }
    });
    html_content = "";
    compileHaml = function() {
      var haml_source;
      haml_source = $('#haml').val();
      localStorage.setItem('haml', haml_source);
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
      if (!((37 <= (_ref = e.which) && _ref <= 40))) {
        return compileHaml();
      }
    });
    js_content = "";
    compileCoffee = function() {
      var coffee_source;
      coffee_source = $('#coffee').val();
      localStorage.setItem('coffee', coffee_source);
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
      if (!((37 <= (_ref = e.which) && _ref <= 40))) {
        return compileCoffee();
      }
    });
    yes_jquery = false;
    yes_underscore = false;
    $('#jquery').bind('click', function() {
      yes_jquery = !yes_jquery;
      localStorage.setItem('has_jquery', yes_jquery);
      return renderPreview();
    });
    $('#underscore').bind('click', function() {
      yes_underscore = !yes_underscore;
      localStorage.setItem('has_underscore', yes_underscore);
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
      if (force == null) {
        force = false;
      }
      if (!(render_timeout != null)) {
        console.log(force);
        t = 500;
        render_timeout = setTimeout(function() {
          var data;
          data = "data:text/html;charset=utf-8,";
          data += "<style>" + ((function() {
            return css_content;
          })()) + "</style>";
          data += "" + ((function() {
            return html_content;
          })());
          if (yes_jquery) {
            data += '<script type="application/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.6.1/jquery.min.js"></script>';
          }
          if (yes_underscore) {
            data += '<script type="application/javascript" src="http://ajax.cdnjs.com/ajax/libs/underscore.js/1.1.6/underscore-min.js"></script>';
          }
          data += "<script>" + js_content + "</script>";
          $('iframe').attr('src', encodeURI(data));
          return render_timeout = null;
        }, t);
      }
    };
    $('.tabs li').first().trigger('click');
    $('#develop').splitter();
    _ref = ['coffee', 'sass', 'haml'];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      type = _ref[_i];
      prev = localStorage.getItem(type);
      if (prev) {
        console.log(typeof prev);
        source[type] = prev;
      }
      $("textarea#" + type).html(source[type]);
      console.log($("textarea" + type));
      console.log(source[type]);
    }
    if (localStorage.getItem('has_jquery') != null) {
      source.has_jquery = localStorage.getItem('has_jquery') === 'true';
    }
    if (localStorage.getItem('has_underscore') != null) {
      source.has_underscore = localStorage.getItem('has_underscore') === 'true';
    }
    yes_jquery = source.has_jquery;
    $('#jquery').attr('checked', yes_jquery);
    yes_underscore = source.has_underscore;
    $('#underscore').attr('checked', yes_underscore);
    compileCoffee();
    compileSass();
    compileHaml();
    return renderPreview(true);
  };
  $(document).ready(init);
}).call(this);
