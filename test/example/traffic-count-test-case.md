# test-traffic-count
引用插件：limit-count[详细说明](https://apisix.apache.org/docs/apisix/plugins/limit-count/)

1. create route
	1. create plugin first, then ingress and crd will reference it, you should rebuild after ingress/crd deleted to reuse it.
	```
	kubectl apply -f traffic-count-plugin.yaml
	```
	2. create by ingress
	```
	kubectl apply -f traffic-count-ingress.yaml
	```
	3. create by apisix crd: apisixroute
	```
	kubectl apply -f traffic-count-route.yaml
	```
2. test shell script
	traffic-count.sh
	```
	#!/bin/bash
	for((i = 0; i < 4; i++)); do
	  curl --resolve traffic.count.com:32555:192.168.49.2 http://traffic.count.com:32555/ip
	  sleep 0.3
	done
	exit 0
	```
	```
	curl -o /dev/null -s -w %{time_total}"\n" --resolve traffic.count.com:32555:192.168.49.2 http://traffic.count.com:32555/ip
	// 实测单次请求总耗时大约15ms，不影响测试
	```
2. test without limit-count
	
	```
	-- request
	./traffic-count.sh
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
3. test limit-count ok
	```
	enable limit-count and set only allow 2 request per second. 即只要一秒内，不管任何时间段，任何间隔，不超过2次即可，超过即拦截
	通过修改脚本休眠时间测试
	```
	1.  sleep 0.6 // 共四个请求，0s、0.6s、1.2s、1.8s发送，任一秒内不超过2个请求，每个请求都可以通过
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
	{
	  "origin": "10.244.0.1"
	}
	```
	2. sleep 0.4 // // 共四个请求，0s、0.4s、0.8s、1.2s发送，前三个请求在1s内，只能通过前两个，第四个在新的1s内，可以通过
	```
	{
	  "origin": "10.244.0.1"
	}
	{
	  "origin": "10.244.0.1"
	}
	{"error_msg":"Requests are too frequest, please try again later."}
	{
	  "origin": "10.244.0.1"
	}
	```
	3. sleep 0.1 // // 共四个请求，0s、0.1s、0.2s、0.3发送，四个请求都在1秒内，只能通过前两个
	```
	{
	  "origin": "10.244.0.1"
	}
	{
	  "origin": "10.244.0.1"
	}
	{"error_msg":"Requests are too frequest, please try again later."}
	{"error_msg":"Requests are too frequest, please try again later."}
	```
	
