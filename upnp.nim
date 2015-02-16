import httpclient, strutils, browsers

echo "Please enter your internal Port e.g. \"8080\""
var port_intern = readLine(stdin)
echo "Please enter your external Port e.g. \"8080\" (If you don't know what to choose use the same)"
var port_extern = readLine(stdin)
echo "Please enter your ip adress (if you don't know your ip on Linux use \"ip addr\", on Windows cmd => \"ipconfig\", on Mac \"ifconfig\". It should look like this \"192.168.1.55\")"
var client_ip = readLine(stdin)
echo "Please enter your gateway adress. If you don't know your gateway adress try your ip adress with a 1 at the last number so if 192.168.178.55 is your ip try 192.168.178.1"
var router_ip = readLine(stdin)
echo "Please enter if you want TCP or UDP. If you dont know what to choose use TCP."
var proto = readLine(stdin)
var headers: string = "Content-Type: text/xml; charset=\"utf-8\"\nSoapAction: urn:schemas-upnp-org:service:WANIPConnection:1#AddPortMapping"
var body: string = ""
body.add("<?xml version=\"1.0\" encoding=\"utf-8\"?> <s:Envelope s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\" xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\"> <s:Body><u:AddPortMapping xmlns:u=\"urn:schemas-upnp-org:service:WANIPConnection:1\"><NewRemoteHost /><NewExternalPort>"& port_extern &"</NewExternalPort><NewProtocol>"& proto &"</NewProtocol><NewInternalPort>"& port_intern &"</NewInternalPort><NewInternalClient>"& client_ip &"</NewInternalClient><NewEnabled>1</NewEnabled><NewPortMappingDescription /><NewLeaseDuration>0</NewLeaseDuration></u:AddPortMapping></s:Body> </s:Envelope>")
var data = newMultipartData()
discard post("http://"& router_ip &":49000/upnp/control/WANIPConn1", headers, body)
echo "Ports are open now.\n\n\n"
echo "Ok as next you will see a webpage with you internet ip und your local ip. Give to your friends the internet ip."
discard readLine(stdin)
openDefaultBrowser "https://diafygi.github.io/webrtc-ips/"
echo "Press 3x Enter to close the port."
discard readLine(stdin)
discard readLine(stdin)
discard readLine(stdin)

body = body.replace("AddPortMapping", "DeletePortMapping")
headers = headers.replace("AddPortMapping", "DeletePortMapping")
discard post("http://"& router_ip &":49000/upnp/control/WANIPConn1", headers, body)
echo "Port should be closed again."
