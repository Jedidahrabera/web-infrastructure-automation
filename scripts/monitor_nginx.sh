#!/bin/bash
echo "$(date): Status Code: $(curl -s -o /dev/null -w "%{http_code}" http://localhost)" >> ~/nginx_monitor.log
