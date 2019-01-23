FROM amazonlinux:2
LABEL maintainer "Anthony Moulen <anthony_moulen@harvard.edu>"
ENV TOMCAT_MAJOR="8" \
    TOMCAT_VERSION="8.5.37" \
    FITS_VERSION="1.4.0" \
    FITSSERVLET_VERSION="1.2.0" \
    FITS_SERVLET_URL="http://projects.iq.harvard.edu/files/fits/files/fits" \
    CATALINA_HOME=/opt/tomcat

# To reuse variables this environment has to exist after the first setting.
ENV TOMCAT_TAR=https://www.apache.org/dyn/closer.cgi?action=download&filename=tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz \
    FITS_URL="https://github.com/harvard-lts/fits/releases/download/$FITS_VERSION/fits-$FITS_VERSION.zip"

# Update Environment:
RUN echo "LANG=en_US.utf-8" >> /etc/profile.d/locale.sh && \
    echo "LC_ALL=en_US.utf-8" >> /etc/profile.d/locale.sh && \
    echo "export LANG LC_ALL" >> /etc/profile.d/locale.sh && \
    yum -y update && \
    yum -y install java-1.8.0-openjdk jpackage-utils javapackages-tools file which tar python27 python27-pip python2-setuptools gpg openssl wget unzip perl util-linux && \
    yum -y clean all && \
    useradd -u 173 -s /sbin/nologin -d /opt/tomcat -m tomcat && \
    easy_install supervisor && \
    echo_supervisord_conf > /etc/supervisord.conf && \
    mkdir /etc/supervisor.d && \
    mkdir /var/lib/supervisor && \
    mkdir /var/log/supervisor && \
    chown tomcat /var/lib/supervisor && \
    chown tomcat /var/log/supervisor

# Copy in local configurations and utilities
COPY supervisord.conf /etc/
COPY supervisor/* /etc/supervisor.d/
COPY java_home.pl /opt/lts_utils/
COPY change_tomcat_id.sh /opt/lts_utils/
RUN mkdir /opt/fits && \
    mkdir /processing && \
    chown tomcat:tomcat /processing && \
    chown -R tomcat:tomcat /opt/lts_utils && \
    chmod +x /opt/lts_utils/* && \
    chown -R tomcat:tomcat /opt/fits

USER tomcat

# Install FITS Application
WORKDIR /opt/fits
RUN curl -Lo fits.zip $FITS_URL && \
    unzip -q fits.zip && \
    rm fits.zip

# Install Tomcat from Apache, based on Tomcat DockerHub Package.
WORKDIR $CATALINA_HOME

RUN wget -O tomcat.tar.gz "$TOMCAT_TAR" && \
    tar -zxf tomcat.tar.gz --strip-components=1 && \
    rm bin/*.bat && \
    rm tomcat.tar.gz && \
    rm -rf webapps && \
    mkdir webapps

USER root
COPY *.properties $CATALINA_HOME/conf/
RUN chmod 775 /opt/lts_utils/* && \
    echo "JAVA_HOME=`/opt/lts_utils/java_home.pl`" >> /etc/java/java.conf && \
    chown -R tomcat:tomcat conf

USER tomcat

# Install FITS Servlet into WebApps folder as ROOT.
RUN curl -o $CATALINA_HOME/webapps/fits.war $FITS_SERVLET_URL-$FITSSERVLET_VERSION.war && \
    mkdir $CATALINA_HOME/webapps/ROOT && \
    echo '<% response.sendRedirect("/fits/"); %>' > $CATALINA_HOME/webapps/ROOT/index.jsp

# Expose our Volume and Ports
VOLUME ["/processing"]

# Web Port
EXPOSE 8080 \
       8009 \
       8443

# Start up Tomcat 8
CMD ["/usr/bin/supervisord"]
