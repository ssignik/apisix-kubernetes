# test-security-cors
引用插件：cors[详细说明](https://apisix.apache.org/docs/apisix/plugins/cors/)

1. create route
	1. create plugin first, then ingress and crd will reference it, you should rebuild after ingress/crd deleted to reuse it.
	```
	kubectl apply -f security-cors-plugin.yaml
	```
	2. create by ingress
	```
	kubectl apply -f security-cors-ingress.yaml
	```
	3. create by apisix crd: apisixroute
	```
	kubectl apply -f security-cors-route.yaml
	```

2. test without cors
	```
	-- request
	curl -H "Origin:http://allow.origin.org" --resolve "security.cors.com:32555:192.168.49.2" http://security.cors.com:32555/openid-configuration -v
	-- response
	without "Access-Control" message

	```
3. test cors ok
	```
	enable cors and set only allow origin: "http://allow.origin.org"
	-- request
	curl -H "Origin:http://allow.origin.org" --resolve "security.cors.com:32555:192.168.49.2" http://security.cors.com:32555/openid-configuration -v
    -- response
    ···
    < Vary: Origin
	< Access-Control-Allow-Origin: http://allow.origin.org
	< Access-Control-Allow-Methods: *
	< Access-Control-Max-Age: 5
	< Access-Control-Expose-Headers: *
	< Access-Control-Allow-Headers: *
	···
	```
4. test not match origin
	```
	allow.origin.com  replace allow.origin.org
	-- request
	curl -H "Origin:http://allow.origin.com" --resolve "security.cors.com:32555:192.168.49.2" http://security.cors.com:32555/openid-configuration -v
	-- response
	without "Access-Control" message

	```