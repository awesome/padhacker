(function() {
  var init;
  init = function() {
    var compileCoffee, compileHaml, compileSass, css_content, html_content, js_content, prev, renderPreview, source, type, yes_jquery, _i, _len, _ref;
    source = {
      haml: "%h1 Hello, world!\n%p\n    Donec id elit non mi porta gravida at eget metus. Donec ullamcorper nulla non metus auctor fringilla. Morbi leo risus, porta ac consectetur ac, vestibulum at eros.\n%img{ src: \"http://code.alecperkins.net/projector/images/cyan-small.jpg\" }",
      sass: "p\n  :font-family 'Trebuchet MS'\n  &.selected\n    :font-weight bold",
      coffee: "p = $('p')\np.click ->\n    p.toggleClass 'selected'",
      has_jquery: true
    };
    $('.tabs li').click(function(e) {
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
    $('#sass').keyup(function(e) {
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
    $('#haml').keyup(function(e) {
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
    $('#coffeescript').keyup(function(e) {
      var _ref;
      if (!((37 <= (_ref = e.which) && _ref <= 40))) {
        return compileCoffee();
      }
    });
    yes_jquery = false;
    $('#jquery').click(function() {
      yes_jquery = !yes_jquery;
      return renderPreview();
    });
    renderPreview = function() {
      var data;
      data = "data:text/html;charset=utf-8,";
      data += "\<style\>" + css_content + "\</style\>";
      data += "" + html_content;
      if (yes_jquery) {
        data += '\<script type="application/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.6.1/jquery.min.js"\>\</script\>';
      }
      data += "\<script\>" + js_content + "\</script\>";
      $('iframe').attr('src', encodeURI(data));
    };
    $('textarea').keydown(function(e) {
      if (e.which === 9) {
        return e.preventDefault();
      }
    });
    $('.tabs li').first().click();
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
    if (localStorage.getItem('has_jquery')) {
      source.has_jquery = localStorage.getItem('has_jquery');
    }
    yes_jquery = source.has_jquery;
    if (source.has_jquery) {
      $('#jquery').attr('checked', true);
    }
    compileCoffee();
    compileSass();
    compileHaml();
    return renderPreview();
  };
  $(document).ready(init);
}).call(this);
