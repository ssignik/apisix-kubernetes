# test-rewrite-host
引用插件：proxy-rewrite[详细说明](https://apisix.apache.org/docs/apisix/plugins/proxy-rewrite/)

1. create route
	1. create plugin first, then ingress and crd will reference it, you should rebuild after ingress/crd deleted to reuse it.
	```
	kubectl apply -f rewrite-host-plugin.yaml
	```
	2. create by ingress
	```
	kubectl apply -f rewrite-host-ingress.yaml
	```
	3. create by apisix crd: apisixroute
	```
	kubectl apply -f rewrite-host-route.yaml
	```

2. test without rewrite-host
	1. inactive plugin in ingress
	```
	# k8s.apisix.apache.org/plugin-config-name: "rewrite-host"
	```
	2. inactive plugin in route
	```
	# plugin_config_name: rewrite-host
	```
	3. get request header
	```
	-- request
	curl --resolve "rewrite.host.com:32555:192.168.49.2" http://rewrite.host.com:32555/headers
	-- response
	{
	  "headers": {
	    "Accept": "*/*", 
	    "Host": "rewrite.host.com:32555", 
	    "User-Agent": "curl/7.81.0", 
	    "X-Forwarded-Host": "rewrite.host.com"
	  }
	}
	```
4. test with rewrite-host
	```
	修改host:"www.rewrite.host.org"
	-- request
	curl --resolve "rewrite.host.com:32555:192.168.49.2" http://rewrite.host.com:32555/headers
    -- response
    {
	  "headers": {
	    "Accept": "*/*", 
	    "Host": "www.rewrite.host.org", 
	    "User-Agent": "curl/7.81.0", 
	    "X-Forwarded-Host": "rewrite.host.com"
	  }
	}
	```