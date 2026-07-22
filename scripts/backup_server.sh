#!/bin/bash
STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost)
if [ "$STATUS_CODE" -eq 200 ]; then
    echo "$(date): OK - Nginx is running healthy" >> /var/log/nginx_monitor.log
else
    echo "$(date): CRITICAL - Nginx is DOWN (Status Code: $STATUS_CODE)" >> /var/log/nginx_monitor.log
fi
