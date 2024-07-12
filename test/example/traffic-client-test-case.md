# test-traffic-client
引用插件：client-control[详细说明](https://apisix.apache.org/docs/apisix/plugins/client-control/)

1. create route
	1. create plugin first, then ingress and crd will reference it, you should rebuild after ingress/crd deleted to reuse it.
	```
	kubectl apply -f traffic-client-plugin.yaml
	```
	2. create by ingress
	```
	kubectl apply -f traffic-client-ingress.yaml
	```
	3. create by apisix crd: apisixroute
	```
	kubectl apply -f traffic-client-route.yaml
	```

2. test without client-control
	```
	-- request
	curl --resolve "traffic.client.com:32555:192.168.49.2" http://traffic.client.com:32555/post -d 'data'
	-- response
	{
	  "args": {}, 
	  "data": "", 
	  "files": {}, 
	  "form": {
	    "data": ""
	  }, 
	  "headers": {
	    "Accept": "*/*", 
	    "Content-Length": "4", 
	    "Content-Type": "application/x-www-form-urlencoded", 
	    "Host": "traffic.client.com:32555", 
	    "User-Agent": "curl/7.81.0", 
	    "X-Forwarded-Host": "traffic.client.com"
	  }, 
	  "json": null, 
	  "origin": "10.244.0.1", 
	  "url": "http://traffic.client.com/post"
	}
	```
3. test client-control ok
	```
	enable client-control and set only allow 4 byte
	```
	1. in limit 
	```
	-- request
	curl --resolve "traffic.client.com:32555:192.168.49.2" http://traffic.client.com:32555/post -d 'data'
	-- response
	{
	  "args": {}, 
	  "data": "", 
	  "files": {}, 
	  "form": {
	    "data": ""
	  }, 
	  "headers": {
	    "Accept": "*/*", 
	    "Content-Length": "4", 
	    "Content-Type": "application/x-www-form-urlencoded", 
	    "Host": "traffic.client.com:32555", 
	    "User-Agent": "curl/7.81.0", 
	    "X-Forwarded-Host": "traffic.client.com"
	  }, 
	  "json": null, 
	  "origin": "10.244.0.1", 
	  "url": "http://traffic.client.com/post"
	}
	```
	2. exceed limit
	```
	-- request
	curl --resolve "traffic.client.com:32555:192.168.49.2" http://traffic.client.com:32555/post -d 'data1' -i
	-- response
	HTTP/1.1 413 Request Entity Too Large
	Date: Wed, 10 Jul 2024 03:02:18 GMT
	Content-Type: text/html; charset=utf-8
	Content-Length: 255
	Connection: close
	Server: APISIX/3.9.1

	<html>
	<head><title>413 Request Entity Too Large</title></head>
	<body>
	<center><h1>413 Request Entity Too Large</h1></center>
	<hr><center>openresty</center>
	<p><em>Powered by <a href="https://apisix.apache.org/">APISIX</a>.</em></p></body>
	</html>
	```
	
