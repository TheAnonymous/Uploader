import os, re,asyncfile, jester, asyncdispatch, htmlgen, asyncnet, net, browsers, parseutils, strutils, parseopt2, cgi
echo "\"./upload insecure\" to share also subdirectorys"
echo "\"./upload 5000\" to serve on port 5000"
echo "\"./upload insecure 5000\" to share also subdirectorys and serve on port 5000"
var port = 8080
var insecure_world = false


var html_temp = ""
html_temp.add "<link href=\"//maxcdn.bootstrapcdn.com/bootstrap/3.3.2/css/bootstrap.min.css\" rel=\"stylesheet\">"
html_temp.add "<link rel=\"stylesheet\" href=\"https://maxcdn.bootstrapcdn.com/bootstrap/3.3.2/css/bootstrap-theme.min.css\">"
html_temp.add "<script src=\"//maxcdn.bootstrapcdn.com/bootstrap/3.3.2/js/bootstrap.min.js\"></script>"
html_temp.add "<script src=\"https://cdnjs.cloudflare.com/ajax/libs/angular.js/1.4.1/angular.js\"></script>"
html_temp.add "<script>var uploaderApp = angular.module('uploader', []);</script>"
html_temp.add "<div ng-app=\"uploader\" class=\"container\"><h1 class=\"text-center\"><strong><a href=\"http://theanonymous.github.io\" target=\"_blank\">Uploader</a></strong><small><p class=\"glyphicon glyphicon-sort\"></p></small></h1><div class=\"row\"><div class=\"col-md-12\">"
html_temp.add "<div class=\"col-md-6\"><form action=\"upload\" method=\"post\"enctype=\"multipart/form-data\" class=\"form-inline\">"
html_temp.add "<div class=\"form-group\">"
html_temp.add "<input type=\"file\" name=\"file\"value=\"file\">"
html_temp.add "</div>"
html_temp.add "<div class=\"form-group\">"
html_temp.add "<button type=\"submit\" value=\"Submit\" name=\"submit\" class=\"btn btn-default\"><span class=\"glyphicon  glyphicon-cloud-upload\" aria-hidden=\"true\"></span> Upload</button>"
html_temp.add "</div>"
html_temp.add "</form></div><div class=\"col-md-6\"><input type=\"text\" placeholder=\"Filter files...\" class=\"form-control\" ng-model=\"query\"></div></div></div>"

proc parseCommArgs()=
  for kind, key, val in getopt():
    case key
    of "insecure", "-i": insecure_world = true
    if parseInt(key, port) == 0:
      discard parseInt(key, port)

proc default() =
  settings:
      port = Port(port)
  routes:

    get "/":
      var html = html_temp
      html.add "<h3>Files</h3>"
      html.add "<table class=\"table table-hover\">"
      for file in walkFiles("*.*"):
          html.add "<tr ng-show=\"'" & file & "'.toLowerCase().search(query.toLowerCase()) !== -1\"><td><a href=\"" & encodeUrl(file) & "\">" & file & "</td></tr>"
      html.add "</table></div>"
      resp(html)

    post "/upload":
      var filename = request.formData["file"].fields["filename"]
      if filename == "":
        resp "Sorry but you have to choose a file first."
      else:
        if (existsFile filename):
          resp("Sorry  but a file with this name already exists!")
        else:
          var file = openAsync(filename, fmReadWrite)
          await file.write(request.formData["file"].body)
          resp("File \"" & filename & "\" is uploaded.</br><a href=\"/\">Bring me back")

    get "/@filename":
      await response.sendHeaders(Http200, {"Content-Type": "application"}.newStringTable())
      var filename = @"filename"
      filename = decodeUrl(filename)
      var file = openAsync(filename, fmRead)
      var data = await file.read(4000)
      while data.len != 0:
        await response.client.send(data)
        data = await file.read(4000)
      file.close()
      response.client.close()
  runForever()

proc insecure()=
  settings:
    port = Port(port)
    staticDir = "./"

  routes:

    get "/":
      var html = html_temp
      html.add "<h3>Folder and files</h3>"
      html.add "<table class=\"table table-hover\">"
      for folder in walkDirRec("./"):
        html.add "<tr><td><a href=\"" & encodeUrl(folder) & "\">" & folder & "</td></tr>"
      html.add "</table></div>"
      resp(html)

    post "/upload":
      var filename = request.formData["file"].fields["filename"]
      if filename == "":
        resp "Sorry but you have to choose a file first."
      else:
        if (existsFile filename):
          resp("Sorry  but a file with this name already exists!")
        else:
          var file = openAsync(filename, fmReadWrite)
          await file.write(request.formData["file"].body)
          resp("File \"" & filename & "\" is uploaded.</br><a href=\"/\">Bring me back")


  runForever()

parseCommArgs()
openDefaultBrowser("http://localhost:" & intToStr(port))

if insecure_world:
  insecure()
else:
  default()
