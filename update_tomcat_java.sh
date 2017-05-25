#!/bin/bash
JAVAHOME=`${BASH_SOURCE%/*}/java_home.pl`
JAVAHOME_UPDATE="JAVA_HOME=${JAVAHOME}"
sed -i "s#JAVA_HOME.*#$JAVAHOME_UPDATE#" /usr/share/tomcat8/conf/tomcat8.conf
