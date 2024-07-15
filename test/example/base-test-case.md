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
4. advanced routing -高级用法-只支持ApisixRoute
	1. method-基于HTTP方法，取值范围：GET,POST,PUT,DELETE,PATCH,HEAD,OPTIONS,CONNECT,TRACE
	将符合指定HTTP方法的请求导向上游服务,可以指定多个，只要满足其中之一即可
	```
	spec:
	  http:
	  - name: baseroute
	    match:
	      hosts:
	      - baseroute.com
	      paths:
	      - /ip
	      methods:
	      - GET
	    backends:
	      - serviceName: httpbin
	        servicePort: 80
	```
	2. exprs-基于表达式，匹配HTTP的queries，headers，cookies等
	一组配置由subject,operator,vaule/set组成
	subject：包含scope和name字段，scope表示查询范围：Header、Query、Cookie，name表示范围内的字段
	operator:操作符：等于-Equal,不等于-NotEqual，大于-GreaterThan，小于-LessThan，在-In，不在-NotIn，正则匹配-RegexMatch（大小写敏感），正则不匹配-RegexNotMatch（大小写敏感），正则匹配-RegexMatchCaseInsensitive（大小写不敏感），正则匹配-RegexNotMatchCaseInsensitive（大小写不敏感）
	value: 目标比对值
	set： 目标比对集合，只用于In/NotIn
	```
	spec:
	  http:
	    - name: rule
	      match:
		    hosts:
		      - baseroute.com
	        paths:
	          - /*
	        exprs:
	          - subject:
	              scope: Query
	              name: id
	            op: Equal
	            value: "123"
	          - subject:
	          	  scope: Header
	          	  name: name
	          	op: RegexMatch
	          	value: "json"
	      backends:
	      - serviceName: httpbin
	        servicePort: 80
	```
5. advanced routing test - method
	1. apply 
	```
	kubectl apply -f base-method-ingress.yaml
	```
	2. method ok
	```
	-- request
	curl --resolve "baseroute.com:32555:192.168.49.2" http://baseroute.com:32555/ip
    -- response
    {"origin":"your ip"} // 对于部署在k8s中，为将流量导向httpbin服务的网卡IP
	```
	2. method not match
	```
	-- request
	curl -X POST -d 'name=json' --resolve "baseroute.com:32555:192.168.49.2" http://baseroute.com:32555/ip
    -- response
    <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
	<title>405 Method Not Allowed</title>
	<h1>Method Not Allowed</h1>
	<p>The method is not allowed for the requested URL.</p>
	```
6. advanced routing test - exprs
	1. apply 
	```
	kubectl apply -f base-exprs-ingress.yaml
	```
	2. method ok
	```
	-- request
	curl -H "name:json" --resolve "baseroute.com:32555:192.168.49.2" http://baseroute.com:32555/get?id=123
    -- response
    {
	  "args": {
	    "id": "123"
	  }, 
	  "headers": {
	    "Accept": "*/*", 
	    "Host": "baseroute.com:32555", 
	    "Name": "json", 
	    "User-Agent": "curl/7.81.0", 
	    "X-Forwarded-Host": "baseroute.com"
	  }, 
	  "origin": "10.244.0.1", 
	  "url": "http://baseroute.com/get?id=123"
	}
	```
	2. method not match header
	```
	-- request
	curl -H "name:Json" --resolve "baseroute.com:32555:192.168.49.2" http://baseroute.com:32555/get?id=123
    -- response
    
	```
	2. method not match query
	```
	-- request
	curl -H "name:json" --resolve "baseroute.com:32555:192.168.49.2" http://baseroute.com:32555/get?id=1234
    -- response
    
	```
	2. method not match both
	```
	-- request
	curl -H "name=JSON" --resolve "baseroute.com:32555:192.168.49.2" http://baseroute.com:32555/get?id=1234
    -- response
    
	```