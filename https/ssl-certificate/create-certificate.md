## create ca
创建配置文件
```
ca-config.json ca-csr.json
``` 
生成CA根证书
```
cfssl gencert -initca ca-csr.json | cfssljson -bare ca
```
得到证书
```
ca.csr ca-key.pem ca.pem
```
## create etcd 
创建配置文件
```
etdc-csr.json
```
生成ETCD服务端证书
```
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=etcd etcd-csr.json | cfssljson  -bare etcd
```
得到证书
```
etcd.csr etcd-key.pem etcd.pem
```
## create apisix 
创建配置文件
```
apisix-csr.json
```
生成APISIX客户端证书
```
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=apisix apisix-csr.json | cfssljson  -bare apisix
```
得到证书
```
apisix.csr apisix-key.pem apisix.pem
```


方式一：通过configmap挂载证书
## create etcd tls configmap
```
kubectl create configmap -n ingress-apisix etcd-tls-config --from-file=ca.pem --from-file=etcd.pem --from-file=etcd-key.pem
```
## create apisix tls configmap
```
kubectl create configmap -n ingress-apisix apisix-tls-config --from-file=ca.pem --from-file=apisix.pem --from-file=apisix-key.pem
```
方式二：通过vault挂载证书
