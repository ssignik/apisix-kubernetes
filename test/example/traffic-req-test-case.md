# test-traffic-req
引用插件：limit-req[详细说明](https://apisix.apache.org/docs/apisix/plugins/limit-req/)

1. create route
	1. create plugin first, then ingress and crd will reference it, you should rebuild after ingress/crd deleted to reuse it.
	```
	kubectl apply -f traffic-req-plugin.yaml
	```
	2. create by ingress
	```
	kubectl apply -f traffic-req-ingress.yaml
	```
	3. create by apisix crd: apisixroute
	```
	kubectl apply -f traffic-req-route.yaml
	```
2. test shell script
	traffic-req.sh
	```
	#!/bin/bash
	for((i = 0; i < 3; i++)); do
	  curl --resolve traffic.req.com:32555:192.168.49.2 http://traffic.req.com:32555/ip
	  sleep 0.3
	done
	exit 0
	```
	```
	curl -o /dev/null -s -w %{time_total}"\n" --resolve traffic.req.com:32555:192.168.49.2 http://traffic.req.com:32555/ip
	// 实测单次请求总耗时大约15ms，不影响测试
	```
2. test without limit-req
	
	```
	-- request
	./traffic-req.sh
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

	```
3. test limit-req ok
	```
	enable limit-req and set only allow 2 request per second. 会匀速发送，2/s = 1/0.5s 即0.5s内只能通过1个请求，超过即拦截
	通过修改脚本休眠时间测试
	```
	1.  sleep 0.5 // 共三个请求，0s、0.5s、1s发送，每个请求都可以通过
	```
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
	2. sleep 0.3 // // 共三个请求，0s、0.3s、0.6s发送，前两个请求在0.5内，只能通过第一个，第三个在1s内，可以通过
	```
	{
	  "origin": "10.244.0.1"
	}
	{"error_msg":"Requests are too frequest, please try again later."}
	{
	  "origin": "10.244.0.1"
	}
	```
	3. sleep 0.1 // // 共三个请求，0s、0.1s、0.2s发送，三个请求都在0.5秒内，只能通过第一次
	```
	{
	  "origin": "10.244.0.1"
	}
	{"error_msg":"Requests are too frequest, please try again later."}
	{"error_msg":"Requests are too frequest, please try again later."}
	```
	
