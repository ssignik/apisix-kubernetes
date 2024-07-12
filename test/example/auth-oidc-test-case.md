# test-auth-oidc
引用插件：openid-connect[详细说明](https://apisix.apache.org/docs/apisix/plugins/openid-connect/)

1. create route
	1. create plugin first, then ingress and crd will reference it, you should rebuild after ingress/crd deleted to reuse it.
	```
	kubectl apply -f auth-oidc-plugin.yaml
	```
	2. create by ingress
	```
	kubectl apply -f auth-oidc-ingress.yaml
	```
	3. create by apisix crd: apisixroute
	```
	kubectl apply -f auth-oidc-route.yaml
	```

2. test without auth-oidc
	1. inactive plugin in ingress
	```
	# k8s.apisix.apache.org/plugin-config-name: "auth-oidc"
	```
	2. inactive plugin in route
	```
	# plugin_config_name: auth-oidc
	```
	3. get request header
	```
	-- request 需通过浏览器 访问后端httpbin服务
	https://local.httpbin.org:8443/get
	-- response
	{
	  "args": {}, 
	  "headers": {
	    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7", 
	    "Accept-Encoding": "gzip, deflate", 
	    "Accept-Language": "en-GB,en-US;q=0.9,en;q=0.8,zh-CN;q=0.7,zh;q=0.6", 
	    "Host": "local.httpbin.org", 
	    "Upgrade-Insecure-Requests": "1", 
	    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36", 
	    "X-Amzn-Trace-Id": "Root=1-668e6531-2908cc0919823a3776a5ecc2", 
	    "X-Forwarded-Host": "local.httpbin.org"
	  }, 
	  "origin": "127.0.0.1, 119.8.52.77", 
	  "url": "http://local.httpbin.org/get"
	}
	```
4. test with auth-oidc
	```
	-- 浏览器 第一次请求
	https://local.httpbin.org:8443/get
    -- response
    跳转 
    https://openeuler-usercenter.test.osinfra.cn/login?client_id=623c3c2f1eca5ad5fca6c58a&scope=openid%20profile%20id_token%20offline_access&redirect_uri=https%3A%2F%2Flocal.httpbin.org%3A8443%2F&response_mode=query&state=468b2a2c6b9932c42943154e772ba04c
    // 输入用户名密码登录
    // 成功后
    跳转到httpbin
    -- response
    {
	    "args": {},
	    "headers": {
	        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7",
	        "Accept-Encoding": "gzip, deflate, br, zstd",
	        "Accept-Language": "zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6",
	        "Cookie": "session=EDM8X5IcdIaUwlnn6ZHLFg|1720612081|IzkXsaG1LeSNACH76U_i ··· session_2=pg5UHHN1ADuczZgBuLa2rLJA|zeEQBAhLdUEyq1U7OlLz3L1Sp9s",
	        "Host": "local.httpbin.org:8443",
	        "Priority": "u=0, i",
	        "Referer": "https://openeuler-usercenter.test.osinfra.cn/",
	        "Sec-Ch-Ua": "\"Not/A)Brand\";v=\"8\", \"Chromium\";v=\"126\", \"Microsoft Edge\";v=\"126\"",
	        "Sec-Ch-Ua-Mobile": "?0",
	        "Sec-Ch-Ua-Platform": "\"Windows\"",
	        "Sec-Fetch-Dest": "document",
	        "Sec-Fetch-Mode": "navigate",
	        "Sec-Fetch-Site": "cross-site",
	        "Upgrade-Insecure-Requests": "1",
	        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36 Edg/126.0.0.0",
	        "X-Access-Token": "dczh4teqUmdDwbTkU ··· Q7PyW4B",
	        "X-Forwarded-Host": "local.httpbin.org",
	        "X-Id-Token": "eyJpc3MiOiJodHRwczovL29wZW5ldWxlcnRlc3QuYXV0a ··· jb25zb2xlL2RlZmF1bHQtdXNlci1hdmF0YXIucG5nIn0=",
	        "X-Userinfo": "eyJwaWN0dXJlIjoiaHR0cH ··· bjE1MCIsIm1pZGRsZV9uYW1lIjpudWxsfQ=="
	    },
	    "origin": "127.0.0.1",
	    "url": "https://local.httpbin.org/get"
	}
	-- request 再次请求
	https://local.httpbin.org:8443/headers
	-- response 无需登录可以访问后端服务
	{
	    "headers": {
	        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7",
	        "Accept-Encoding": "gzip, deflate, br, zstd",
	        "Accept-Language": "zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6",
	        "Cookie": "session=EDM8X5IcdIaU  ··· g8bPH-EIcOzffdE",
	        "Host": "local.httpbin.org:8443",
	        "Priority": "u=0, i",
	        "Referer": "https://openeuler-usercenter.test.osinfra.cn/",
	        "Sec-Ch-Ua": "\"Not/A)Brand\";v=\"8\", \"Chromium\";v=\"126\", \"Microsoft Edge\";v=\"126\"",
	        "Sec-Ch-Ua-Mobile": "?0",
	        "Sec-Ch-Ua-Platform": "\"Windows\"",
	        "Sec-Fetch-Dest": "document",
	        "Sec-Fetch-Mode": "navigate",
	        "Sec-Fetch-Site": "cross-site",
	        "Sec-Fetch-User": "?1",
	        "Upgrade-Insecure-Requests": "1",
	        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36 Edg/126.0.0.0",
	        "X-Access-Token": "ahIH7XNThg0v-X ··· jcC9VlKoBRMz9kJq1JhUa",
	        "X-Forwarded-Host": "local.httpbin.org",
	        "X-Id-Token": "eyJ1cGRhdGVkX2F0  ··· widXNlcm5hbWUiOiJ6aGFveWFuMTUwIiwicHJlZmVycmVkX3VzZXJuYW1lIjpudWxsfQ=="
	    }
	}
	```