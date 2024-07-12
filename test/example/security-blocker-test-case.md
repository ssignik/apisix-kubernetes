# test-security-block
引用插件：uri-blocker[详细说明](https://apisix.apache.org/docs/apisix/plugins/uri-blocker/)

1. create route
	1. create plugin first, then ingress and crd will reference it, you should rebuild after ingress/crd deleted to reuse it.
	```
	kubectl apply -f security-blocker-plugin.yaml
	```
	2. create by ingress
	```
	kubectl apply -f security-blocker-ingress.yaml
	```
	3. create by apisix crd: apisixroute
	```
	kubectl apply -f security-blocker-route.yaml
	```

2. test without blocker
	```
	-- request
	curl --resolve "security.blocker.com:32555:192.168.49.2" http://security.blocker.com:32555/ip
	-- response
	{
	  "origin": "10.244.0.1"
	}

	```
3. test blocker ok
	```
	enable blocker and set deny: ["^/ip"], and erros msg: "access is not allowed."
	-- request
	curl --resolve "security.blocker.com:32555:192.168.49.2" http://security.blocker.com:32555/ip
    -- response
    {"error_msg":"access is not allowed."}
	```
4. test not match uri
	```
	allow.origin.com  replace allow.origin.org
	-- request
	curl --resolve "security.blocker.com:32555:192.168.49.2" http://security.blocker.com:32555/get
	-- response
	{
	  "args": {}, 
	  "headers": {
	    "Accept": "*/*", 
	    "Host": "security.blocker.com:32555", 
	    "User-Agent": "curl/7.81.0", 
	    "X-Forwarded-Host": "security.blocker.com"
	  }, 
	  "origin": "10.244.0.1", 
	  "url": "http://security.blocker.com/get"
	}
	```