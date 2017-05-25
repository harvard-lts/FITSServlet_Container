FROM amazonlinux:latest
MAINTAINER "Anthony Moulen <anthony_moulen@harvard.edu>"

# Update Environment:
RUN yum -y update && \
    yum -y install python27 python27-pip && \
    easy_install supervisor && \
    echo_supervisord_conf > /etc/supervisord.conf && \
    mkdir /etc/supervisor.d && \
    echo "[include]" >> /etc/supervisord.conf && \
    echo "files=/etc/supervisor.d/*.conf" >> /etc/supervisord.conf

ADD tomcat.conf /etc/supervisor.d/

# Install Java on Amazon Linux:
RUN yum install -y wget unzip perl util-linux && \
    wget --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.rpm && \
    yum localinstall -y jdk*rpm

# Install Tomcat from Amazon Repo:
RUN yum install -y tomcat8 && \
    mkdir /opt/lts_utils

# Deal with bad setting for JAVA_HOME in tomcat8.conf
ADD java_home.pl /opt/lts_utils
ADD update_tomcat_java.sh /opt/lts_utils
RUN chmod 775 /opt/lts_utils/* && \
    echo "JAVA_HOME=`/opt/lts_utils/java_home.pl`" >> /etc/java/java.conf && \
    /opt/lts_utils/update_tomcat_java.sh

# Install FITS Application
ADD http://projects.iq.harvard.edu/files/fits/files/fits-1.1.0.zip /opt

RUN mkdir /processing && \
    chown tomcat:tomcat /processing && \
    cd /opt ; unzip -q fits-*.zip ; rm /opt/fits*.zip ; mv /opt/fits-* /opt/fits && \
    chown -R tomcat:tomcat /opt/fits

# Update Settings and Install FITS servlet
ADD catalina.properties /usr/share/tomcat8/conf
ADD http://projects.iq.harvard.edu/files/fits/files/fits-1.1.3.war /tmp
ADD fits-service.properties /usr/share/tomcat8/conf
RUN cd /usr/share/tomcat8/webapps ; chmod g+rws . && \
    mv /tmp/fits*.war /usr/share/tomcat8/webapps/ROOT.war && \
    chown tomcat:tomcat /usr/share/tomcat8/webapps/ROOT.war && \
    chgrp -R tomcat /etc/tomcat8 && \
    chmod -R g+r /etc/tomcat8

# Expose our Volume and Ports
VOLUME ["/processing"]
# Web Port
EXPOSE 8080
# AJP Port
EXPOSE 8009
# SSL Port (NOTE: SSL is not configured by default.)
EXPOSE 8443

# Start up Tomcat 8
WORKDIR /usr/share/tomcat8
CMD ["/usr/local/bin/supervisord"]
