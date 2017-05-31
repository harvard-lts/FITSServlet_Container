#!/bin/bash
JAVAHOME=`${BASH_SOURCE%/*}/java_home.pl`
JAVAHOME_UPDATE="JAVA_HOME=${JAVAHOME}"
sed -i "s#JAVA_HOME.*#$JAVAHOME_UPDATE#" /opt/tomcat/conf/tomcat8.conf
