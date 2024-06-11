## create ca
```
cfssl gencert -initca ca-csr.json | cfssljson -bare ca
```
## create etcd 
```
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=apisix etcd-csr.json | cfssljson  -bare etcd
```
## create etcd tls configmap
```
kubectl create configmap -n ingress-apisix etcd-tls-config --from-file=ca.pem --from-file=etcd.pem --from-file=etcd-key.pem
```
## create apisix 
```
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=apisix apisix-csr.json | cfssljson  -bare etcd
```
## create apisix tls configmap
```
kubectl create configmap -n ingress-apisix apisix-tls-config --from-file=ca.pem --from-file=apisix.pem --from-file=apisix-key.pem
```