#!/bin/bash
count=4
for((i = 0; i < count; i++)); do
  curl --resolve traffic.conn.com:32555:192.168.49.2 http://traffic.conn.com:32555/ip &
done
wait
exit 0