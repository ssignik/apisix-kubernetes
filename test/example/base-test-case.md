# test-base

1. create route
	1. create by ingress
	```
	kubectl apply -f base-ingress.yaml
	```
	2. create by apisix crd: apisixroute
	```
	kubectl apply -f base-route.yaml
	```

2. test ok
	```
	-- request
	curl --resolve "baseroute.com:32555:192.168.49.2" http://baseroute.com:32555/ip
    -- response
    {"origin":"your ip"} // 对于部署在k8s中，为将流量导向httpbin服务的网卡IP
	```
3. test 404 not found
	1. not match host
	```
	baseroute.org  replace baseroute.com
	-- request
	curl --resolve "baseroute.org:32555:192.168.49.2" http://baseroute.org:32555/ip
	-- response
	{"error_msg":"404 Route Not Found"}

	```
	2. not match uri
	```
	/ip  replace /get
	-- request
	curl --resolve "baseroute.com:32555:192.168.49.2" http://baseroute.com:32555/get
	-- response
	{"error_msg":"404 Route Not Found"}

	```