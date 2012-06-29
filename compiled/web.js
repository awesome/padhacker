// Generated by CoffeeScript 1.3.3
(function() {
  var PORT, app, express;

  express = require('express');

  app = express.createServer(express.logger());

  app.get('/', function(request, response) {
    return response.send('Hello Worldx!');
  });

  PORT = process.env.PORT || 5000;

  app.listen(PORT, function() {
    return console.log("Listening on " + PORT);
  });

}).call(this);
