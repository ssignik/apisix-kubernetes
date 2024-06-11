APISIX 迁移文档
该文档主要针对当前网关ingress-nginx-controller迁移到ingress-apisix-controller实施方案
## 基础功能清单
1.route
1.a ingress
```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: regex-ingress
  annotations:
    k8s.apisix.apache.org/rewrite-target-regex: "/admin(/|$)(.*)"
    k8s.apisix.apache.org/rewrite-target-regex-template: "/$2"
spec:
  ingressClassName: apisix
  rules:
    - host: example.com
      http:
        paths:
          - path: /admin*
            pathType: Prefix
            backend:
              service:
                name: httpbin
                port: 
                  number: 80
```
1.b apisixroute
注意：apisixroute的path如果没有*就默认是精确匹配Exact:/不匹配/admin，如果需要前缀匹配，先使用/*
```
apiVersion: apisix.apache.org/v2
kind: ApisixRoute
metadata:
  name: example-route
spec:
  http:
  - name: example
    match:
      hosts:
      - example.com
      paths:
      - "/*"
    backends:
    - serviceName: httpbin
      servicePort: 80
```
2.https
2.a ingress - secret
unsupported
2.b crd - apisixtls - secret
create secret
```
kubectl create secret tls example-secret --cert=./tls.crt --key=./tls.key
```
create apisixtls
```
apiVersion: apisix.apache.org/v2
kind: ApisixTls
metadata:
  name: example-tls
spec:
  hosts:
    - example.com
  secret:
    name: example-secret
    namespace: default
```

then we can use at any apisixroute that listen the host: example.com and doesnot need extra config at route

```
apiVersion: apisix.apache.org/v2
kind: ApisixRoute
metadata:
  name: example-route
spec:
  http:
  - name: example
    match:
      hosts:
      - example.com
      paths:
      - "/*"
    backends:
    - serviceName: httpbin
      servicePort: 80
```
3.path

## 额外功能清单
1.rewrite
2.location deny
3.cors
4.proxy-body-size
5.add_header
6.permanent-redirect
7.traffic-limit

### 1.rewrite
```
annotations:
  nginx.ingress.kubernetes.io/server-snippet: |
    rewrite ^/$ https://example.com/index;
```
#### 1.a ingress - annotations
```
annotations:
  k8s.apisix.apache.org/rewrite-target-regex: "^/$"
  k8s.apisix.apache.org/rewrite-target-regex-template: "/ip"
```
#### 1.b plugin - proxy-rewrite
create one plugin config
```
apiVersion: apisix.apache.org/v2
kind: ApisixPluginConfig
metadata:
  name: rewrite-target
spec:
  plugins:
  - name: proxy-rewrite
    enable: true
    config:
      regex_uri: ["^/$","/ip"]
```
ingress
```
annotations:
    k8s.apisix.apache.org/plugin-config-name: "rewrite-target"
```
crd
```
apiVersion: apisix.apache.org/v2
kind: ApisixRoute
metadata:
  name: rewrite-route
spec:
  http:
  - name: example
    match:
      hosts:
      - example.com
      paths:
      - /
    backends:
      - serviceName: httpbin
        servicePort: 80
    plugin_config_name: rewrite-target
```
#### test
```
// 返回500响应
curl -ikv --resolve "example.com:32106:192.168.49.2" "http://example.com:32106/"
// 返回IP
```
#### rewrite regex uri [flag] 域名重写，uri重写
```
rewrite ^(.*) https://a.cn/b/c redirect;
```
对应plugin配置
```
apiVersion: apisix.apache.org/v2
kind: ApisixPluginConfig
metadata:
  name: rewrite-target
spec:
  plugins:
  - name: proxy-rewrite
    enable: true
    config:
      host: "a.cn"
      regex_uri: ["^(.*)","/b/c"]
```
### 2.location deny
```
annotations:
  nginx.ingress.kubernetes.io/server-snippet: |
    location ^~ /admin {
      deny all;
    }
  nginx.ingress.kubernetes.io/custom-http-errors: "500"
```
#### 1.a ingress - annotations 
unsupported
#### 1.b plugin - uri-blocker
```
apiVersion: apisix.apache.org/v2
kind: ApisixPluginConfig
metadata:
  name: uri-blocker
spec:
  plugins:
  - name: uri-blocker
    enable: true
    config:
      block_rules: ["^/admin"],
      rejected_code: 500
```
ingress
```
annotations:
    k8s.apisix.apache.org/plugin-config-name: "uri-blocker"
```
crd
```
apiVersion: apisix.apache.org/v2
kind: ApisixRoute
metadata:
  name: uri-blocker-route
spec:
  http:
  - name: example
    match:
      hosts:
      - example.com
      paths:
      - /*
    backends:
      - serviceName: httpbin
        servicePort: 80
    plugin_config_name: uri-blocker
```
#### test
```
curl -ikv --resolve "example.com:32106:192.168.49.2" "http://example.com:32106/admin"
// 返回500响应
curl -ikv --resolve "example.com:32106:192.168.49.2" "http://example.com:32106/admin/v1"
// 返回500响应
curl -ikv --resolve "example.com:32106:192.168.49.2" "http://example.com:32106/ip"
// 返回IP
```
### 3.cors
host: a.b.cn
```
annotations:
  nginx.ingress.kubernetes.io/cors-allow-origin: "https://*.a.org, https://b.cn, https://*.b.cn"
  nginx.ingress.kubernetes.io/enable-cors: "true"
```
#### 3.a ingress - annotations
```
annotations:
  k8s.apisix.apache.org/enable-cors: "true"
  k8s.apisix.apache.org/cors-allow-origin: "https://*.a.org, https://b.cn, https://*.b.cn""
```
#### 3.b plugin - cors
```
apiVersion: apisix.apache.org/v2
kind: ApisixPluginConfig
metadata:
  name: cors
spec:
  plugins:
  - name: cors
    enable: true
    config:
      allow_origins_by_regex: https://*.a.org, https://b.cn, https://*.b.cn",
```
ingress
```
annotations:
    k8s.apisix.apache.org/plugin-config-name: "cors"
```
crd
```
apiVersion: apisix.apache.org/v2
kind: ApisixRoute
metadata:
  name: cors-route
spec:
  http:
  - name: example
    match:
      hosts:
      - example.com
      paths:
      - /*
    backends:
      - serviceName: httpbin
        servicePort: 80
    plugin_config_name: cors
```
### 4. proxy-body-size
```
annotations:
  nginx.ingress.kubernetes.io/proxy-body-size: 2m
```
#### 4.a ingress - annotations
unsupported
#### 4.b plugin - client-control
```
apiVersion: apisix.apache.org/v2
kind: ApisixPluginConfig
metadata:
  name: request-body-size
spec:
  plugins:
  - name: client-control
    enable: true
    config:
      max_body_size: 2,
```
ingress
```
annotations:
    k8s.apisix.apache.org/plugin-config-name: "request-body-size"
```
crd
```
apiVersion: apisix.apache.org/v2
kind: ApisixRoute
metadata:
  name: request-body-size-route
spec:
  http:
  - name: example
    match:
      hosts:
      - example.com
      paths:
      - /*
    backends:
      - serviceName: httpbin
        servicePort: 80
    plugin_config_name: request-body-size
```
### 5. add_header
```
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/configuration-snippet: |
      add_header Content-Security-Policy "script-src 'self' 'unsafe-inline' 'unsafe-eval'; object-src 'none'; frame-ancestors 'self'";
      add_header X-XSS-Protection "1; mode=block";
      add_header X-Frame-Options "DENY";
      add_header Cache-Control "no-cache";
      add_header Pragma "no-cache";
      add_header X-Content-Type-Options "nosniff";
```
#### 5.a ingress - annotations
unsupported
#### 5.b plugin - proxy-rewrite
```
apiVersion: apisix.apache.org/v2
kind: ApisixPluginConfig
metadata:
  name: add-header
spec:
  plugins:
  - name: proxy-rewrite
    enable: true
    config:
      headers: {
        "add": {
          "Content-Security-Policy": "script-src 'self' 'unsafe-inline' 'unsafe-eval'; object-src 'none'; frame-ancestors 'self'",
          "X-XSS-Protection": "1; mode=block",
          "X-Frame-Options": "DENY",
          "Cache-Control": "no-cache",
          "Pragma": "no-cache",
          "X-Content-Type-Options": "nosniff"
        }
      }
```
ingress
```
annotations:
    k8s.apisix.apache.org/plugin-config-name: "add-header"
```
crd
```
apiVersion: apisix.apache.org/v2
kind: ApisixRoute
metadata:
  name: add-header-route
spec:
  http:
  - name: example
    match:
      hosts:
      - example.com
      paths:
      - /*
    backends:
      - serviceName: httpbin
        servicePort: 80
    plugin_config_name: add-header
```
### 6. permanent-redirect
host: www.a.io
```
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/permanent-redirect: https://a.io
 ```
#### 6.a ingress - annotation
unsupported
#### 6.b plugin - redirect (未测通)
注意：需要准备www.example.com和example.com两个域名的证书
```
openssl genrsa -out tls.key 2048
openssl req -new -x509 -key tls.key -days 10000 -out tls.crt -subj /C=CN/ST=BeiJing/L=BeiJing/O=DevOps/CN=www.example.com
```
```
apiVersion: apisix.apache.org/v2
kind: ApisixPluginConfig
metadata:
  name: 301-redirect
spec:
  plugins:
  - name: redirect
    enable: true
    config:
      uri: "https://example.com$request_uri"
      ret_code: 301
```
ingress
```
annotations:
    k8s.apisix.apache.org/plugin-config-name: "301-redirect"
```
crd
```
apiVersion: apisix.apache.org/v2
kind: ApisixRoute
metadata:
  name: 301-redirect-route
spec:
  http:
  - name: example
    match:
      hosts:
      - www.example.com
      paths:
      - /*
    backends:
      - serviceName: httpbin
        servicePort: 80
    plugin_config_name: 301-redirect
```
#### 6.c plugin - proxy-rewrite (测通)
注意：需要准备www.example.com和example.com两个域名的证书
```
openssl genrsa -out tls.key 2048
openssl req -new -x509 -key tls.key -days 10000 -out tls.crt -subj /C=CN/ST=BeiJing/L=BeiJing/O=DevOps/CN=www.example.com
```
```
apiVersion: apisix.apache.org/v2
kind: ApisixPluginConfig
metadata:
  name: host-rewrite
spec:
  plugins:
  - name: proxy-rewrite
    enable: true
    config:
      host: "example.com:30316"
      regex_uri: ["(.*)","$1"]
```
ingress
```
annotations:
    k8s.apisix.apache.org/plugin-config-name: "host-rewrite"
```
crd
```
apiVersion: apisix.apache.org/v2
kind: ApisixRoute
metadata:
  name: host-rewrite-route
spec:
  http:
  - name: example
    match:
      hosts:
      - www.example.com
      paths:
      - /*
    backends:
      - serviceName: httpbin
        servicePort: 80
    plugin_config_name: host-rewrite
```
### 7 traffic-limit
```
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/limit-connections: "400"
    nginx.ingress.kubernetes.io/limit-rps: "400"
 ```
#### 7.a ingress - annotation
unsupported
#### 7.b plugin - limit-conn limit-req
plugin config
```
apiVersion: apisix.apache.org/v2
kind: ApisixPluginConfig
metadata:
  name: traffic-limit
spec:
  plugins:
  - name: limit-req
    enable: true
    config:
      #exceed rate will delay request 
      rate: 3
      #exceed rate + burst will reject request
      burst: 0
      #condition that count the request：remote_addr,server_addr,http_x_real_ip,http_x_forward_for,consumer_name
      key: "remote_addr"
  - name: limit-conn
    enable: true
    config:
      #exceed conn will delay request 
      conn: 3
      #exceed conn + burst will reject request
      burst: 0
      #exceed limit delay request time
      default_conn_delay: 0.1
      #condition that count the request：remote_addr,consumer_name
      key: "remote_addr"
```
ingress
```
annotations:
    k8s.apisix.apache.org/plugin-config-name: "traffic-limit"
```
crd
```
apiVersion: apisix.apache.org/v2
kind: ApisixRoute
metadata:
  name: traffic-limit-route
spec:
  http:
  - name: example
    match:
      hosts:
      - www.example.com
      paths:
      - /*
    backends:
      - serviceName: httpbin
        servicePort: 80
    plugin_config_name: traffic-limit
```