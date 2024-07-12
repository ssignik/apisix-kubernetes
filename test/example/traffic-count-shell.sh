#!/bin/bash
for((i = 0; i < 3; i++)); do
  curl --resolve traffic.count.com:32555:192.168.49.2 http://traffic.count.com:32555/ip
  sleep 0.1
done
exit 0