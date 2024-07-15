# apisix test
## 测试环境
1. 运行环境：kubernetes
2. 部署APISIX网关，查看[部署文档](https://github.com/ssignik/apisix-kubernetes)
3. 部署demo服务
	目录：webemo
	1. nginx
	创建目录：nginx
	```
	kubectl create configmap -n ingress-apisix nginx-configmap --from-file=nginx.conf --from-file=openid-configuration.json --from-file=index.html
	kubectl apply -f nginx.yaml
	```
	2. httpbin
	创建目录：httpbin
	```
	kubectl apply -f httpbin.yaml
	// Demo官网https://httpbin.org/，以下可用于测试
	// /ip 获取请求IP，样例：https://httpbin.org/ip
	// /get 获取请求信息，样例：https://httpbin.org/get
	// /headers 获取请求头信息，样例：https://httpbin.org/headers
	// /response-headers 获取响应头信息，样例：https://httpbin.org/response-headers
	```
	3. canary
	创建目录:go
	```
	// 该demo用于灰度发布测试
	// canary-v1.go/cancary-v2.go 为demo代码，可自定义内容
	// 根据Dockerfile分别创建v1-v2的镜像
	// 进入构建目录,创建v1镜像
	cp canary-v1.go canary-demo.go
	docker build -t canary-demo:v1 .
	// 创建v2镜像
	cp canary-v2.go canary-demo.go
	docker build -t canary-demo:v2 .
	// 部署
	// docker
	docker run -p 8080:8080 canary-demo:v1
	docker run -p 8080:8080 canary-demo:v2
	// k8s
	kubectl apply -f cancary-v1.yaml
	kubectl apply -f cancary-v2.yaml
	// 测试
	// 版本v1
	请求：/version 
	响应："Hello, Version 1!"
	// 版本v2
	请求：/version 
	响应："Hello, Version 2!"
	```
4. 准备测试域名及匹配证书
	域名准备列表
	1. local.httpbin.org
	2. example.com
	3. `www.example.com`
	4. httptest.com(可以是任何自定义域名)

	配置本地dns映射
	```
	windows路径： C:\Windows\System32\drivers\etc\hosts
	linux路径： /etc/hosts
	-------内容-----
	ip local.httpbin.org
	ip example.com
	ip example.com
	ip httptest.com
	```
	创建tls证书
	目录：tls
	```
	// 创建local.httpbin.org目录，得到tls.crt和tls.key
	openssl genrsa -out tls.key 2048
	openssl req -new -x509 -key tls.key -days 10000 -out tls.crt -subj /C=CN/ST=BeiJing/L=BeiJing/O=DevOps/CN=local.httpbin.org
	// 创建example.com目录，得到tls.crt和tls.key
	openssl genrsa -out tls.key 2048
	openssl req -new -x509 -key tls.key -days 10000 -out tls.crt -subj /C=CN/ST=ShangHai/L=ShangHai/O=DevOps/CN=example.com
	// 创建www.example.com目录，得到tls.crt和tls.key
	openssl genrsa -out tls.key 2048
	openssl req -new -x509 -key tls.key -days 10000 -out tls.crt -subj /C=CN/ST=GuangDong/L=Guangzhou/O=DevOps/CN=www.example.com
	// httptest.com 用于测试http请求，无需tls证书
	```
## 基础功能测试
目录：example
```
// 单点部署：`http://<node-ip>:<apisix-gateway:port>`
// 集群部署：`http://<elb-ip>:<expose:port>` // expose:port为elb暴露端口，匹配上游的apisix-gateway:port
// 当前测试入口 
// apisix admin api
192.168.49.2:32180 
// http 
192.168.49.2:32555 
// https
192.168.49.2:30330
```

<table>
	<tr>
		<td>功能</td><td>次级</td><td>创建文件</td><td>测试用例</td>
	</tr>
	<tr>
		<td rowspan="2" colspan="2">路由</td><td>base-route.yaml</td><td rowspan="2">base-test-case.md</td>
	</tr>
	<tr>
		<td>base-ingress.yaml</td>
	</tr>
	<tr>
		<td rowspan="2" colspan="2">https支持</td><td>https-route.yaml</td><td rowspan="2">https-test-case.md</td>
	</tr>
	<tr>
		<td>https-ingress.yaml</td>
	</tr>
	<tr>
		<td rowspan="6">信息重写</td><td rowspan="3">请求头</td><td>rewrite-header-plugin.yaml</td><td rowspan="3">rewrite-header-test-case.md</td>
	</tr>
	<tr>
		<td>rewrite-header-route.yaml</td>
	</tr>
	<tr>
		<td>rewrite-header-ingress.yaml</td>
	</tr>
	</tr>
	<tr>
		<td rowspan="3">域名</td><td>rewrite-host-plugin.yaml</td><td rowspan="3">rewrite-host-test-case.md</td>
	</tr>
	<tr>
		<td>rewrite-host-route.yaml</td>
	</tr>
	<tr>
		<td>rewrite-host-ingress.yaml</td>
	</tr>
	<tr>
		<td rowspan="6">安全</td><td rowspan="3">跨域</td><td>security-cors-plugin.yaml</td><td rowspan="3">security-cors-test-case.md</td>
	</tr>
	<tr>
		<td>security-cors-route.yaml</td>
	</tr>
	<tr>
		<td>security-cors-ingress.yaml</td>
	</tr>
	</tr>
	<tr>
		<td rowspan="3">请求拦截</td><td>security-blocker-plugin.yaml</td><td rowspan="3">security-blocker-test-case.md</td>
	</tr>
	<tr>
		<td>security-blocker-route.yaml</td>
	</tr>
	<tr>
		<td>security-blocker-ingress.yaml</td>
	</tr>
	<tr>
		<td rowspan="12">流量控制</td><td rowspan="3">请求体大小</td><td>traffic-client-plugin.yaml</td><td rowspan="3">traffic-client-test-case.md</td>
	</tr>
	<tr>
		<td>traffic-client-route.yaml</td>
	</tr>
	<tr>
		<td>traffic-client-ingress.yaml</td>
	</tr>
	</tr>
	<tr>
		<td rowspan="3">请求速率-漏桶算法</td><td>traffic-req-plugin.yaml</td><td rowspan="3">traffic-req-test-case.md</td>
	</tr>
	<tr>
		<td>traffic-req-route.yaml</td>
	</tr>
	<tr>
		<td>traffic-req-ingress.yaml</td>
	</tr>
	<tr>
		<td rowspan="3">请求速率-固定窗口</td><td>traffic-count-plugin.yaml</td><td rowspan="3">traffic-count-test-case.md</td>
	</tr>
	<tr>
		<td>traffic-count-route.yaml</td>
	</tr>
	<tr>
		<td>traffic-count-ingress.yaml</td>
	</tr>
	<tr>
		<td rowspan="3">请求并发数</td><td>traffic-conn-plugin.yaml</td><td rowspan="3">traffic-conn-test-case.md</td>
	</tr>
	<tr>
		<td>traffic-conn-route.yaml</td>
	</tr>
	<tr>
		<td>traffic-conn-ingress.yaml</td>
	</tr>
	<tr>
		<td rowspan="3">集中认证</td><td rowspan="3">OIDC</td><td>auth-oidc-plugin.yaml</td><td rowspan="3">auth-oidc-test-case.md</td>
	</tr>
	<tr>
		<td>auth-oidc-route.yaml</td>
	</tr>
	<tr>
		<td>auth-oidc-ingress.yaml</td>
	</tr>
	<tr>
		<td rowspan="2" colspan="2">灰度发布</td><td>canary-weight-route.yaml</td><td rowspan="2">canary-release-test-case.md</td>
	</tr>
	<tr>
		<td>canary-rules-route.yaml</td>
	</tr>
</table>
