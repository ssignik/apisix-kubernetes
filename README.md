# APISIX简介
## 简介
APISIX 是 Apache 软件基金会下的项目。它是一个具有动态、实时、高性能等特点的云原生 API 网关，它提供了动态路由、动态上游、动态证书、A/B 测试、灰度发布（金丝雀发布）、蓝绿部署、限速、防攻击、收集指标、监控报警、可观测、服务治理等功能。
APISIX构建于 NGINX + ngx_lua 的技术基础之上
## 架构

## 组件
APISIX：网关核心
Dashboard：控制面UI
Ingress Controller：Kubernetes原生Ingress实现
ETCD： 数据存储
## 构建
apisix需要先构建rpm包，查看[shell脚本](https://github.com/opensourceways/apisix-build-tools)
示例：基于openeuler，选择cve修复分支创建
```
git clone -b build-base-openeuler https://github.com/opensourceways/apisix-build-tools.git
cd apisix-build-tools
// 设置脚本可执行权限
chown +x *.sh
make package type=rpm app=apisix version=3.9.1-cve checkout=3.9.1-cve image_base=openeuler/openeuler image_tag=22.03
ls output
apisix-3.9.1-cve-0.el7.x86_64.rpm
```
## 镜像
ETCD、APISIX、Apisix-Dashboard、Apisix-Ingress-Controller四个组件构建docker镜像

基于openeuler/openeuler:22.03

查看[镜像制作说明](https://github.com/opensourceways/apisix-docker/tree/build-base-openeuler/openeuler)

## 部署
部署架构
![image](https://github.com/user-attachments/assets/14ae7f64-78d5-4937-ae7b-8f9239f51f0a)

基于k8s部署：查看[部署脚本库](https://github.com/ssignik/apisix-kubernetes)

http版本：http目录

https版本：https目录

## 测试
[测试说明](https://github.com/ssignik/apisix-kubernetes/blob/main/migration/Migrate%20from%20NGINX%20to%20APISIX.md)

[测试用例](https://github.com/ssignik/apisix-kubernetes/tree/main/migration/example)

[测试指引](https://github.com/ssignik/apisix-kubernetes/blob/main/test/test-case.md)

## Nginx 迁移
[迁移文档](https://github.com/ssignik/apisix-kubernetes/blob/main/migration)
