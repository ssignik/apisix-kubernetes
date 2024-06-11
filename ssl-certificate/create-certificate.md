## create ca
```
cfssl gencert -initca ca-csr.json | cfssljson -bare ca
```
## create etcd 
```
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=apisix etcd-csr.json | cfssljson  -bare etcd
```
## create configmap
```
kubectl create configmap -n ingress-apisix etcd-tls-config --from-file=ca.pem --from-file=etcd.pem --from-file=etcd-key.pem
```