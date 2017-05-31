FROM amazonlinux:latest
MAINTAINER "Anthony Moulen <anthony_moulen@harvard.edu>"
ENV TOMCAT_MAJOR 8
ENV TOMCAT_VERSION 8.0.44
ENV FITS_VERSION 1.1.1
ENV FITSSERVLET_VERSION 1.1.3

# Update Environment:
RUN yum -y update && \
    yum -y install python27 python27-pip gpg openssl wget unzip perl util-linux && \
    easy_install supervisor && \
    echo_supervisord_conf > /etc/supervisord.conf && \
    mkdir /etc/supervisor.d && \
    echo "[include]" >> /etc/supervisord.conf && \
    echo "files=/etc/supervisor.d/*.conf" >> /etc/supervisord.conf

ADD tomcat.conf /etc/supervisor.d/
RUN mkdir /opt/lts_utils && \
    useradd -u 15001 -s /sbin/nologin -d /opt/tomcat -m tomcat && \
    chown tomcat:tomcat /opt/lts_utils
ADD java_home.pl /opt/lts_utils
ADD update_tomcat_java.sh /opt/lts_utils
RUN chown -R tomcat:tomcat /opt/lts_utils

# Install Java on Amazon Linux:
RUN wget --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.rpm && \
    yum localinstall -y jdk*rpm && \
    yum install -y jpackage-utils javapackages-tools

# Install FITS Application
ADD http://projects.iq.harvard.edu/files/fits/files/fits-$FITS_VERSION.zip /opt

RUN mkdir /processing && \
    chown tomcat:tomcat /processing && \
    cd /opt ; unzip -q fits-*.zip ; rm /opt/fits*.zip ; mv /opt/fits-* /opt/fits && \
    chown -R tomcat:tomcat /opt/fits

# Amazon Install Broken:
# Install Tomcat from Amazon Repo:
#RUN yum install -y tomcat8 && \
#    mkdir /opt/lts_utils
# Install From Apache, based on Tomcat DockerHub Package.
ENV CATALINA_HOME /opt/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH

USER tomcat
WORKDIR $CATALINA_HOME

ENV TOMCAT_TAR https://www.apache.org/dyn/closer.cgi?action=download&filename=tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz

RUN wget -O tomcat.tar.gz "$TOMCAT_TAR" && \
    tar -xvf tomcat.tar.gz --strip-components=1 && \
    rm bin/*.bat && \
    rm tomcat.tar.gz && \
    rm -rf webapps && \
    mkdir webapps

USER root
# Deal with bad setting for JAVA_HOME in tomcat8.conf
RUN chmod 775 /opt/lts_utils/* && \
    echo "JAVA_HOME=`/opt/lts_utils/java_home.pl`" >> /etc/java/java.conf

USER tomcat
# Update Settings and Install FITS servlet
ADD catalina.properties $CATALINA_HOME/conf
ADD http://projects.iq.harvard.edu/files/fits/files/fits-$FITSSERVLET_VERSION.war /tmp
ADD fits-service.properties $CATALINA_HOME/conf
USER root
RUN chown tomcat:tomcat /tmp/fits*war && \
    chown -R tomcat:tomcat conf
USER tomcat
RUN mv /tmp/fits*.war $CATALINA_HOME/webapps/ROOT.war && \
    chown tomcat:tomcat $CATALINA_HOME/webapps/ROOT.war

# Expose our Volume and Ports
VOLUME ["/processing"]
# Web Port
EXPOSE 8080
# AJP Port
EXPOSE 8009
# SSL Port (NOTE: SSL is not configured by default.)
EXPOSE 8443

# Start up Tomcat 8
CMD ["/usr/local/bin/supervisord"]
