# test-traffic-conn
引用插件：limit-conn[详细说明](https://apisix.apache.org/docs/apisix/plugins/limit-conn/)

1. create route
	1. create plugin first, then ingress and crd will reference it, you should rebuild after ingress/crd deleted to reuse it.
	```
	kubectl apply -f traffic-conn-plugin.yaml
	```
	2. create by ingress
	```
	kubectl apply -f traffic-conn-ingress.yaml
	```
	3. create by apisix crd: apisixroute
	```
	kubectl apply -f traffic-conn-route.yaml
	```
2. test shell script
	traffic-conn.sh
	```
	#!/bin/bash
	count=4
	for((i = 0; i < count; i++)); do
	  curl --resolve traffic.conn.com:32555:192.168.49.2 http://traffic.conn.com:32555/ip
	done
	exit 0
	```
	```
	// 通过该方式会有些许误差
	```
2. test without limit-conn
	
	```
	-- request
	./traffic-conn.sh
	-- response
	{
	  "origin": "10.244.0.1"
	}
	{
	  "origin": "10.244.0.1"
	}
	{
	  "origin": "10.244.0.1"
	}
	{
	  "origin": "10.244.0.1"
	}

	```
3. test limit-conn ok
	```
	enable limit-conn and set only allow 2 request on time. 同时并发不超过2次即可，超过即拦截
	通过修改请求数count测试
	```
	1. count 4 // 共四个请求，超过最大并发，只能通过2个
	```
	{"error_msg":"Requests are too frequest, please try again later."}
	{"error_msg":"Requests are too frequest, please try again later."}
	{
	  "origin": "10.244.0.1"
	}
	{
	  "origin": "10.244.0.1"
	}
	```
	2. count 3 // // 共三个请求，大于最大并发，只能通过2个
	```
	{"error_msg":"Requests are too frequest, please try again later."}
	{
	  "origin": "10.244.0.1"
	}
	{
	  "origin": "10.244.0.1"
	}
	```
	3. count 2 // // 共二个请求，等于最大并发，全部通过
	```
	{
	  "origin": "10.244.0.1"
	}
	{
	  "origin": "10.244.0.1"
	}
	```
	
