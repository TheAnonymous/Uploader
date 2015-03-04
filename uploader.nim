import os, re, jester, asyncdispatch, htmlgen, asyncnet, net, browsers, parseutils, strutils, parseopt2
echo "\"./upload insecure\" to share also subdirectorys"
echo "\"./upload 5000\" to serve on port 5000"
echo "\"./upload insecure 5000\" to share also subdirectorys and serve on port 5000"
var port = 8080
var insecure_world = false

proc parseCommArgs()=
  for kind, key, val in getopt():
    case key
    of "insecure", "-i": insecure_world = true
    if parseInt(key, port) == 0:
      discard parseInt(key, port)

proc default()=
  settings:
      port = Port(port)
  routes:
    
    get "/":
      var html = ""
      html.add "<form action=\"upload\" method=\"post\"enctype=\"multipart/form-data\">"
      html.add "<input type=\"file\" name=\"file\"value=\"file\">"
      html.add "<input type=\"submit\" value=\"Submit\" name=\"submit\">"
      html.add "</form>"
      html.add "<h3>Files</h3>"
      for file in walkFiles("*.*"):
          html.add "<li><a href=\"" &file & "\">" & file & "</li>"
      resp(html)
      
    post "/upload":
      var filename = request.formData["file"].fields["filename"]
      if filename == "":
        resp "Sorry but you have to choose a file first."
      else:
        if (existsFile filename):
          resp("Sorry  but a file with this name already exists!")
        else:
          writeFile(filename, request.formData["file"].body)
          resp("File \"" & filename & "\" is uploaded.<a href=\"/\">Bring me back")
      
    get "/@filename":
      var file = readFile(@"filename")
      await response.send(file)
      response.client.close()
  runForever()
  
proc insecure()=
  settings:
    port = Port(port)
  routes:
  
    get "/":
      var html = ""
      html.add "<form action=\"upload\" method=\"post\"enctype=\"multipart/form-data\">"
      html.add "<input type=\"file\" name=\"file\"value=\"file\">"
      html.add "<input type=\"submit\" value=\"Submit\" name=\"submit\">"
      html.add "</form>"
      html.add "<h3>Folder and files</h3>"
      for folder in walkDirRec("./"):
        html.add "<li><a href=\"" &folder & "\">" & folder & "</li>"
      html.add "<h3>Files</h3>"
      resp(html)
      
    post "/upload":
      var filename = request.formData["file"].fields["filename"]
      if filename == "":
        resp "Sorry but you have to choose a file first."
      else:
        if (existsFile filename):
          resp("Sorry  but a file with this name already exists!")
        else:
          writeFile(filename, request.formData["file"].body)
          resp("File \"" & filename & "\" is uploaded.<a href=\"/\">Bring me back")
      
    get re"\/.*":
      var path = request.pathInfo
      if hostOS == "windows":
        path = path.replace(re"%5C", "\\")
      path = "." & path
      var file = readFile(path)
      await response.send(file)
      response.client.close()
    
  runForever()
  
parseCommArgs()
openDefaultBrowser("http://localhost:" & intToStr(port))

if insecure_world:
  insecure()
else:
  default()
  
  
  

