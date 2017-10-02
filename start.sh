#!/bin/bash

#Start tomcat7 - although it fails
echo "Tomcat7 start script says it fails to start even when it's successful"
service tomcat7 start
service guacd start

tail -f /var/log/tomcat7/catalina.out &

wait
