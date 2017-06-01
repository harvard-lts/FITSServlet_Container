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

# Copy in local configurations and utilities
COPY tomcat.conf /etc/supervisor.d/
COPY java_home.pl /opt/lts_utils/
RUN mkdir /opt/fits && \
    useradd -u 15001 -s /sbin/nologin -d /opt/tomcat -m tomcat && \
    mkdir /processing && \
    chown tomcat:tomcat /processing && \
    chown -R tomcat:tomcat /opt/lts_utils && \
    chown -R tomcat:tomcat /opt/fits

# Install Java on Amazon Linux:
RUN wget --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.rpm && \
    yum localinstall -y jdk*rpm && \
    yum install -y jpackage-utils javapackages-tools

USER tomcat
# Install FITS Application
WORKDIR /opt/fits
RUN curl -o fits.zip http://projects.iq.harvard.edu/files/fits/files/fits-$FITS_VERSION.zip && \
    unzip fits.zip && \
    rm fits.zip && \
    mv fits* REMOVEME && \
    mv REMOVEME/* . && \
    rmdir REMOVEME

# Install From Apache, based on Tomcat DockerHub Package.
ENV CATALINA_HOME /opt/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH

WORKDIR $CATALINA_HOME

ENV TOMCAT_TAR https://www.apache.org/dyn/closer.cgi?action=download&filename=tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz

RUN wget -O tomcat.tar.gz "$TOMCAT_TAR" && \
    tar -xvf tomcat.tar.gz --strip-components=1 && \
    rm bin/*.bat && \
    rm tomcat.tar.gz && \
    rm -rf webapps && \
    mkdir webapps

USER root
COPY catalina.properties $CATALINA_HOME/conf
COPY fits-service.properties $CATALINA_HOME/conf
RUN chmod 775 /opt/lts_utils/* && \
    echo "JAVA_HOME=`/opt/lts_utils/java_home.pl`" >> /etc/java/java.conf && \
    chown -R tomcat:tomcat conf

USER tomcat
# Install FITS Servlet into WebApps folder as ROOT.
RUN curl -o $CATALINA_HOME/webapps/ROOT.war http://projects.iq.harvard.edu/files/fits/files/fits-$FITSSERVLET_VERSION.war

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
