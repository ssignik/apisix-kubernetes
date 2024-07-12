# test-rewrite-header
引用插件：proxy-rewrite[详细说明](https://apisix.apache.org/docs/apisix/plugins/proxy-rewrite/)

1. create route
	1. create plugin first, then ingress and crd will reference it, you should rebuild after ingress/crd deleted to reuse it.
	```
	kubectl apply -f rewrite-header-plugin.yaml
	```
	2. create by ingress
	```
	kubectl apply -f rewrite-header-ingress.yaml
	```
	3. create by apisix crd: apisixroute
	```
	kubectl apply -f rewrite-header-route.yaml
	```

2. test without rewrite-header
	1. inactive plugin in ingress
	```
	# k8s.apisix.apache.org/plugin-config-name: "rewrite-header"
	```
	2. inactive plugin in route
	```
	# plugin_config_name: rewrite-header
	```
	3. get request header
	```
	-- request
	curl --resolve "rewrite.header.com:32555:192.168.49.2" http://rewrite.header.com:32555/headers
	-- response
	{
	  "headers": {
	    "Accept": "*/*", 
	    "Host": "rewrite.header.com:32555", 
	    "User-Agent": "curl/7.81.0", 
	    "X-Forwarded-Host": "rewrite.header.com"
	  }
	}
	```
4. test with rewrite-header
	```
	新增header:"Cache-Control": "no-cache","customer": "add-header"
	修改header:"User-Agent": "Mozilla/5.0"
	删除header:"Accept"
	-- request
	curl --resolve "rewrite.header.com:32555:192.168.49.2" http://rewrite.header.com:32555/headers
    -- response
    {
	  "headers": {
	    "Cache-Control": "no-cache", 
	    "Customer": "add-header", 
	    "Host": "rewrite.header.com:32555", 
	    "User-Agent": "Mozilla/5.0", 
	    "X-Forwarded-Host": "rewrite.header.com"
	  }
	}
	```