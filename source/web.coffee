express = require 'express'

app = express.createServer(express.logger())

app.get '/', (request, response) ->
  response.send('Hello Worldx!')


PORT = process.env.PORT or 5000
app.listen PORT, ->
  console.log("Listening on " + PORT)
