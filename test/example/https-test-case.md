# test-https

1. create route
	1. create by ingress
	```
	kubectl apply -f https-ingress.yaml
	```
	2. create by apisix crd: apisixroute
	```
	kubectl apply -f https-route.yaml
	```

2. create tls first to test https
	
	首先进入证书存放目录，可以通过下面其中之一创建证书

	1. create by apisix admin
	```
	-- set sni: local.httpbin.org
   	curl http://192.168.49.2:32180/apisix/admin/ssls/1 -H 'X-API-KEY: 61908c436e12301eccb302e829d941d7' -X PUT -d '
	{
     	"cert" : "'"$(cat tls.crt)"'",
     	"key": "'"$(cat tls.key)"'",
     	"snis": ["local.httpbin.org"]
	}'
	```
	2. create by k8s:secret + apisix-ingress-controler:apisixtls
	```
	// secret
   	kubectl create secret tls local-httpbin-secret --cert=./tls.crt --key=./tls.key -n ingress-apisix
   	// apisixtls : apisix-tls-local-httpbin.yaml
   	kubectl apply -f apisix-tls-local-httpbin.yaml
	```

3. test https ok
    注意：这里要切换成https端口：30330，之前为http端口:32555
	```
	-- request
	curl -ikv --resolve "local.httpbin.org:30330:192.168.49.2" https://local.httpbin.org:30330/ip
    -- response
    {"origin":"your ip"} // 对于部署在k8s中，为将流量导向httpbin服务的网卡IP
	```
4. test https handshake failed
	1. not match host
	```
	-- request
	curl -ikv --resolve "local.httpbin.com:30330:192.168.49.2" https://local.httpbin.com:30330/ip
    -- response
    {"origin":"your ip"} // 对于部署在k8s中，为将流量导向httpbin服务的网卡IP
	```