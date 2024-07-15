# test-canary
引用插件：traffic-split[详细说明](https://apisix.apache.org/docs/apisix/plugins/traffic-split/)

1. plugin information
   当前插件目前无法很好的支持Ingress
   灰度实现主要依赖CRD-ApisixRoute的路由规则匹配和权重
   路由匹配规则参考高级实现：base-test-case.md 、 base-exprs-route.yaml
2. create route
  1. create by apisix crd: weight-based
  ```
  kubectl apply -f canary-weight-route.yaml
  ```
  2. create by apisix crd: rules-based
  ```
  kubectl apply -f canary-rules-route.yaml
  ```
3. 说明
  1. weight-based
  核心配置：weight，根据配置的权重比例来分配流量，
  示例中：v1的weight:10，v2的weight：5，也就是v1会分得2/3的流量，v2会分得1/3的流量，流量随机分配
  ```
  spec:
    http:
    - name: rule1
      priority: 1
      match:
        hosts:
        - canary.com
        paths:
        - /version
      backends:
        - serviceName: canary-v1
          servicePort: 8080
          weight: 10
        - serviceName: canary-v2
          servicePort: 8080
          weight: 5
    ```
  2. rules-base
  核心配置：
  Exprs: 可以根据请求头-Header，查询参数-Query中的参数，筛选请求
  priority: 优先级，值越大优先级越高
  示例中： rule2优先级2，先匹配，如果请求中query参数id < 123，并且请求头参数version=v2，则导向canary-v2,剩下的导向canary-v1
  ```
  spec:
    http:
    - name: rule1
      priority: 1
      match:
        hosts:
        - canary.com
        paths:
        - /version
      backends:
        - serviceName: canary-v1
          servicePort: 8080
    - name: rule2
      priority: 2
      match:
        hosts:
        - canary.com
        paths:
        - /version
        exprs:
          - subject:
              scope: Query
              name: id
            op: LessThan
            value: "123"
          - subject:
              scope: Header
              name: version
            op: RegexMatch
            value: "v2"
      backends:
        - serviceName: canary-v2
          servicePort: 8080
  ```
3. weight-based test
  ```
  -- request
  hc=$(seq 60 | xargs -I {} curl --resolve "canary.weight.com:32672:192.168.49.2" http://canary.weight.com:32672/version -sL | grep -o "1" | wc -l); echo version 1: $hc, version 2: $((60 - $hc))
  -- response
  version 1: 40, version 2: 20
  ```
4. rules-based test
  1. rule to v2
  ```
  -- request
  curl --resolve "canary.rules.com:32672:192.168.49.2" http://canary.rules.com:32672/version?id=120 -H "version:v2" -w '\n'
  -- response
  Hello, Version 2!
  ```
  2. rule to v1 -- Q-id=123 H-version:v2
  ```
  -- request
  curl --resolve "canary.rules.com:32672:192.168.49.2" http://canary.rules.com:32672/version?id=123 -H "version:v2" -w '\n'
  -- response
  Hello, Version 1!
  ```
  3. rule to v1 -- Q-id=120 H-version:v1
  ```
  -- request
  curl --resolve "canary.rules.com:32672:192.168.49.2" http://canary.rules.com:32672/version?id=120 -H "version:v1" -w '\n'
  -- response
  Hello, Version 1!
  ```
  4. rule to v1
  ```
  -- request
  curl --resolve "canary.rules.com:32672:192.168.49.2" http://canary.rules.com:32672/version -w '\n'
  -- response
  Hello, Version 1!
  ```